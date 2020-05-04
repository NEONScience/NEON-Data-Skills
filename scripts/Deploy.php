<?php

if (PHP_SAPI !== 'cli') {
    return;
}

/**
 * @var array
 */
const EXCLUDED_MARKDOWN_FILES = ["readme"];

// ******************************
// ******** CLI Script **********
// ******************************

$commitHash = getLastImportCommitHash() ?? null;

printf(
    "The last imported commit hash %s!",
    !empty($commitHash) ? $commitHash : 'is empty'
);

foreach (findTutorialMarkdownFiles($commitHash) as $markdownFile) {
    if (!file_exists($markdownFile)) {
        continue;
    }
    $fileObject = new \SplFileObject($markdownFile);

    $fileObjectName = strtolower(
        $fileObject->getBasename('.md')
    );

    if (in_array($fileObjectName, EXCLUDED_MARKDOWN_FILES)) {
        continue;
    }

    if ($payload = buildContentPayload($fileObject)) {
        if ($httpUrl = getenv('WEBHOOK_HTTP_URL')) {
            $response = httpRequest("{$httpUrl}/neon-tutorials/webhook-capture", 'POST', $payload);

            if ($response['code'] !== 200) {
                printf(
                    "Error: Got a %d an when posting the payload for %s!",
                    $response['code'],
                    $fileObject->getRealPath()
                );
            }
        }
    }
}
$newCommitHash = shell_exec('git rev-parse HEAD');

if ($commitHash !== $newCommitHash) {
    printf(
        "The updated imported commit hash %s!",
        $newCommitHash
    );
    setLastImportCommitHash($newCommitHash);
}

exit(0);

// ******************************
// ******* CLI Functions ********
// ******************************

/**
 * Find all the tutorial markdown files.
 *
 * @param string|null $commit
 *   The last commit hash that was deployed.
 *
 * @return array
 *   An array of all the markdown files.
 */
function findTutorialMarkdownFiles(string $commit = null): array
{
    $command = $commit
        ? "git diff --name-only HEAD {$commit} \"tutorials/*.md\""
        : 'git ls-files "tutorials/*.md"';

    $shellOutput = shell_exec($command);

    if (!isset($shellOutput)) {
        return [];
    }

    return array_filter(explode("\n", $shellOutput));
}

/**
 * Get the last import commit hash.
 *
 * @return string|null
 *   Return the last import commit hash from state.
 */
function getLastImportCommitHash()
{
    if ($httpUrl = getenv('WEBHOOK_HTTP_URL')) {
        $response = httpRequest("{$httpUrl}/neon-tutorials/last-commit/get");

        if ($response['code'] == 200) {
            if ($body = json_decode($response['body'], true)) {
                return trim($body['data']['hash']) ?? null;
            }
        }
    }

    return null;
}

/**
 * Set the last import commit hash.
 *
 * @param string $hash
 *   The git commit hash.
 *
 * @return bool
 *   Return true if successful; otherwise false.
 */
function setLastImportCommitHash(string $hash): bool
{
    if ($httpUrl = getenv('WEBHOOK_HTTP_URL')) {
        $response = httpRequest(
            "{$httpUrl}/neon-tutorials/last-commit/set",
            'POST',
            ['hash' => $hash]
        );

        if ($response['code'] == 200) {
            return true;
        }
    }

    return false;
}

/**
 * Execute a HTTP request.
 *
 * @param string $url
 *   The HTTP URL.
 * @param string $method
 *   The HTTP method.
 * @param array $payload
 *   The payload data array.
 * @param bool $signature
 *   Set the payload to be signed.
 *
 * @return array
 *   An array of the response data.
 */
function httpRequest(string $url, string $method = 'GET', array $payload = [], bool $signature = true): array
{
    $curl = curl_init($url);

    $method = strtoupper($method);
    $headers = ['Content-Type:application/json'];

    if ($method === 'POST' && !empty($payload)) {
        $payload = json_encode($payload);

        if (
            $signature
            && $privateKey = getenv('WEBHOOK_PRIVATE_KEY')
        ) {
            $hmacSignature = base64_encode(hash_hmac(
                'sha256', $payload, $privateKey, true
            ));
            $headers[] = "X-Webhook-Signature:{$hmacSignature}";
        }
        curl_setopt($curl, CURLOPT_POST, true);
        curl_setopt($curl, CURLOPT_POSTFIELDS, $payload);
    }
    curl_setopt($curl, CURLINFO_HEADER_OUT, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($curl);
    $responseCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);

    curl_close($curl);

    return [
        'body' => $response,
        'code' => $responseCode,
    ];
}

/**
 * Build the Markdown content payload.
 *
 * @param \SplFileObject $fileObject
 * @return array
 *   An array of the payload structure.
 */
function buildContentPayload(\SplFileObject $fileObject): array
{
    $payload = [
        'content' => null,
    ];
    $fileObject->rewind();

    while ($fileObject->valid()) {
        $buffer = $fileObject->fgets();

        if (strpos(trim($buffer), '---') !== false) {
            while ($innerBuffer = trim($fileObject->fgets())) {
                if (strpos($innerBuffer, '---') !== false) {
                    continue 2;
                }
                list($key, $value) = array_map(
                    'trim',
                    explode(': ', $innerBuffer)
                );
                $payload[$key] = preg_replace('/(^[\"\']|[\"\']$)/', '', $value);
            };
        }
        $payload['content'] .= $buffer;
    }

    return $payload;
}

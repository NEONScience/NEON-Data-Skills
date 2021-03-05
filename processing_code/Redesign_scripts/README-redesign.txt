## Redesign README ##

	Starting from the existing NEON-Data-Skills/master/ repo, you will want to move all of the tutorials into a directory called "old-tutorials". From there, you can follow these instructions for starting from scratch:
	
	1) Delete anything in the /dev-aten/NEON-Data-Skills/tutorials/ directory (if there is anything)
	2) Run "Redesign-move-md-files-to-new-structure.R"
		a. This moves (almost) all .md files from /old-tutorials/ to their new file structure
	3) Run "Redesign-move-Rmd-files-to-new-structure.R"
		a. This moves (almost) all .Rmd files to their new home. It also deletes .md files if they are in the same directory (because they will need to be remade by knitting) and adds a NOT_VALIDATED.txt file as a flag that this directory/tutorial must be validated before publishing
	4) Run "Redesign_replace_graphics_URLs.R" 
		a. This replaces all {{ site.baseurl }} references with the appropriate link to a permanent URL
	5) Next step would be to replace the _includes HTML with appropriate HTML/md text
	6) Also, need to re-map graphics filepaths when available Redesign_remap_graphics_URLs.R - this will search for filenames of graphics that have been moved and update the links accordingly.

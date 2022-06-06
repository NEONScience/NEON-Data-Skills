# NOTES:
# richness = H, Diversity = H, q = 0
# Shannon entropy = H, Diversity = exp(H), q = 1
# Renyi entropy = H, Diversity = exp(H), q can be anything

# un-even distribution, order q = 0 diversity = 10
dat <- data.frame(spp.a = 90, spp.b = 2, spp.c = 1, 
                  spp.d = 1, spp.e = 1, spp.f = 1, 
                  spp.g = 1, spp.h = 1, spp.i = 1, 
                  spp.j = 1)

dat2 <- data.frame(
  a=c(1,10,3),
  b=c(2,2,2),
  c=c(10,1,5))

library(vegan)
data(BCI)


library(iNEXT)

result_iNEXT <- iNEXT::iNEXT(unlist(dat), q = c(0,1,2))
result_iNEXT$iNextEst %>% dplyr::filter(method=="observed") %>% dplyr::select(order, qD)

vegetarian::d(dat, lev="alpha", q = 0)
vegetarian::d(dat, lev="alpha", q = 1)
vegetarian::d(dat, lev="alpha", q = 2)


exp(vegan::renyi(dat, scales = c(0,1,2)))


vegetarian::d(dat2, lev="alpha", q = 2)
vegetarian::d(dat2, lev="beta", q = 2)
vegetarian::d(dat2, lev="gamma", q = 2)

vegan::multipart(dat2, scales=2)

result_iNEXT <- iNEXT(x = data.frame(t(dat2)), q = 2)
alpha_iNEXT <-result_iNEXT$iNextEst %>% 
  dplyr::bind_rows() %>% 
  dplyr::filter(method=="observed") %>% 
  dplyr::select(qD) %>%
  unlist() %>%
  mean()


result_iNEXT <- iNEXT(x = colMeans(dat2), q = 2)
gamma_iNEXT <- result_iNEXT$iNextEst %>% 
  dplyr::bind_rows() %>% 
  dplyr::filter(method=="observed") %>% 
  dplyr::select(qD)











# these are the same
vegan::multipart(BCI, index="tsallis", scales = 0)
vegan::multipart(BCI, index="renyi", scales = 0)

vegetarian::d(BCI, lev = "alpha", q = 0)
vegetarian::d(BCI, lev = "beta", q = 0)
vegetarian::d(BCI, lev = "gamma", q = 0)


# checking q = 1
# these are the same

my_alpha <- vegan::diversity(BCI, index = "shannon") %>% exp() %>% mean() 
my_gamma <- vegan::diversity(colMeans(BCI), index = "shannon") %>% exp() #doesn't matter if col mean or sum
my_beta <- my_gamma/my_alpha
print(c(my_alpha,my_beta,my_gamma))

vegan::multipart(BCI, index="tsallis", scales = 1)
vegan::multipart(BCI, index="renyi", scales = 1)

result_iNEXT <- iNEXT::iNEXT(BCI, q=1, datatype = "abundance", nboot = 5)


# checking q = 2
my_alpha <- vegan::diversity(BCI, index = "shannon", base = exp(2)) %>% exp() %>% mean() 
my_gamma <- vegan::diversity(colMeans(BCI), index = "shannon", base = exp(2)) %>% exp()
my_beta <- my_gamma/my_alpha

vegan::multipart(BCI, index="tsallis", scales = 2)
vegan::multipart(BCI, index="renyi", scales = 2)
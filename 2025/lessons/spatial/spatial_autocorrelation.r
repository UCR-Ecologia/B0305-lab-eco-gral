# Simulate spatially autocorrelated quadrat counts + Moran's I
# Requires: mvtnorm, spdep
simulate_spatial_autocorr <- function(
  nx = 10,
  ny = 10, # grid size (ignored if coords provided)
  spacing = 2, # distance between quadrat centers
  coords = NULL, # optional matrix/data.frame with columns x,y
  beta0 = log(3), # baseline log-mean
  sigma2 = 1, # marginal variance of Gaussian field
  phi = 6, # range/decay (larger -> smoother field)
  kernel = c("exp", "gaussian"), # covariance kernel
  family = c("poisson", "nbinom"), # count family
  size = 10, # NegBin 'size' (theta): larger -> nearer Poisson
  k_nn = 4, # k nearest neighbors for Moran's I
  seed = NULL, # reproducible RNG seed
  return_cov = FALSE, # return covariance matrix? (can be large)
  nugget = 1e-8 # tiny jitter for numerical stability
) {
  kernel <- match.arg(kernel)
  family <- match.arg(family)
  if (!is.null(seed)) {
    set.seed(seed)
  }

  # -- Coordinates of quadrat centers
  if (is.null(coords)) {
    grid <- expand.grid(ix = 1:nx, iy = 1:ny)
    grid$x <- grid$ix * spacing
    grid$y <- grid$iy * spacing
    coords_mat <- as.matrix(grid[, c("x", "y")])
  } else {
    stopifnot(all(c("x", "y") %in% colnames(as.data.frame(coords))))
    coords_mat <- as.matrix(coords[, c("x", "y")])
    grid <- data.frame(
      ix = NA,
      iy = NA,
      x = coords_mat[, 1],
      y = coords_mat[, 2]
    )
  }
  n <- nrow(coords_mat)

  # -- Distance matrix
  D <- as.matrix(dist(coords_mat))

  # -- Covariance matrix Sigma
  Sigma <- switch(
    kernel,
    exp = sigma2 * exp(-D / phi),
    gaussian = sigma2 * exp(-(D^2) / (2 * phi^2))
  )
  diag(Sigma) <- diag(Sigma) + nugget

  # -- Sample Gaussian random field Z ~ MVN(0, Sigma)
  if (requireNamespace("mvtnorm", quietly = TRUE)) {
    Z <- as.numeric(mvtnorm::rmvnorm(1, sigma = Sigma))
  } else if (requireNamespace("MASS", quietly = TRUE)) {
    Z <- as.numeric(MASS::mvrnorm(1, mu = rep(0, n), Sigma = Sigma))
  } else {
    stop("Please install either 'mvtnorm' or 'MASS'.")
  }

  # -- Intensity and counts
  eta <- beta0 + Z
  lambda <- exp(eta)
  counts <- switch(
    family,
    poisson = rpois(n, lambda),
    nbinom = rnbinom(n, mu = lambda, size = size)
  )

  # -- Moran's I using k-NN graph
  if (!requireNamespace("spdep", quietly = TRUE)) {
    warning("Package 'spdep' not installed; skipping Moran's I.")
    moran_counts <- moran_field <- NULL
    nb <- lw <- NULL
  } else {
    knn <- spdep::knearneigh(coords_mat, k = k_nn)
    nb <- spdep::knn2nb(knn)
    lw <- spdep::nb2listw(nb, style = "W")
    moran_counts <- spdep::moran.test(counts, lw)
    moran_field <- spdep::moran.test(Z, lw)
  }

  out <- list(
    data = data.frame(
      x = coords_mat[, 1],
      y = coords_mat[, 2],
      Z = Z,
      eta = eta,
      lambda = lambda,
      count = counts
    ),
    params = list(
      nx = nx,
      ny = ny,
      spacing = spacing,
      beta0 = beta0,
      sigma2 = sigma2,
      phi = phi,
      kernel = kernel,
      family = family,
      size = size,
      k_nn = k_nn,
      nugget = nugget
    ),
    moran = list(counts = moran_counts, field = moran_field),
    nb = if (exists("nb")) nb else NULL,
    lw = if (exists("lw")) lw else NULL,
    Sigma = if (return_cov) Sigma else NULL
  )
  class(out) <- c("spaut_sim", class(out))
  out
}

if (FALSE) {
  sim <- simulate_spatial_autocorr(
    nx = 12,
    ny = 12,
    spacing = 2,
    phi = 8,
    sigma2 = 1.2,
    beta0 = log(2.5),
    kernel = "exp",
    family = "poisson",
    k_nn = 4,
    seed = 123
  )

  # Moran's I (counts and latent field)
  sim$moran$counts$estimate["Moran I statistic"]
  sim$moran$counts$p.value
  sim$moran$field$estimate["Moran I statistic"]
  sim$moran$field$p.value

  # Quick bubble plot
  plot(
    sim$data$x,
    sim$data$y,
    cex = scales::rescale(sim$data$count, to = c(0.6, 3)),
    main = "Spatial Poisson field (counts)",
    xlab = "x",
    ylab = "y"
  )
}

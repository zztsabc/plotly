context("api")

test_that("api() returns endpoints", {
  skip_on_cran()
  
  res <- api()
  expect_true(length(res) > 1)
  expect_true(all(c("plots", "grids", "folders") %in% names(res)))
})

test_that("Can search with white-space", {
  skip_on_cran()
  
  res <- api("search?q=overdose drugs")
  expect_true(length(res) > 1)
})

test_that("Changing a filename works", {
  skip_on_cran()
  
  id <- new_id()
  f <- api("files/cpsievert:14680", "PATCH", list(filename = id)) 
  expect_equal(f$filename, id)
})


test_that("Downloading plots works", {
  skip_on_cran()
  
  # https://plot.ly/~cpsievert/200
  p <- api_download_plot(200, "cpsievert")
  expect_is(p, "htmlwidget")
  expect_is(p, "plotly")
  
  l <- plotly_build(p)$x
  expect_length(l$data, 1)
  
  # This file is a grid, not a plot https://plot.ly/~cpsievert/14681
  expect_error(
    api_download_plot(14681, "cpsievert"), "grid"
  )
})


test_that("Downloading grids works", {
  skip_on_cran()
  
  g <- api_download_grid(14681, "cpsievert")
  expect_is(g, "api_file")
  expect_is(
    tibble::as_tibble(g$preview), "data.frame"
  )
  
  # This file is a plot, not a grid https://plot.ly/~cpsievert/14681
  expect_error(
    api_download_grid(200, "cpsievert"), "plot"
  )
})


test_that("Creating produces a new file by default", {
  skip_on_cran()
  
  expect_new <- function(obj) {
    old <- api("folders/home?user=cpsievert")
    new_obj <- api_create(obj)
    new <- api("folders/home?user=cpsievert")
    n <- if (is.plot(new_obj)) 2 else 1
    expect_equal(old$children$count + n, new$children$count)
  }
  
  expect_new(mtcars)
  expect_new(qplot(1:10))
})


test_that("Can overwrite a file", {
  skip_on_cran()
  skip_if_not(!interactive())
  
  m <- api_create(mtcars, "mtcars")
  mfile <- api_lookup_file("mtcars")
  m2 <- api_create(iris, "mtcars")
  m2file <- api_lookup_file("mtcars")
  expect_false(identical(mfile$preview, m2file$preview))
})




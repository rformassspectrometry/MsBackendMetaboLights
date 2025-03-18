test_that(".retry works", {
    a <- function() {
        if (sample(0:1, 1) == 0)
            stop("A, got a 0")
        1
    }

    set.seed(123)
    expect_error(.retry(a()), "A, got a 0")
    res <- .retry(a())
    expect_equal(res, 1)
})

test_that(".sleep_mult works", {
    expect_equal(.sleep_mult(), 5L)
})

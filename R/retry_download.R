#' Retry an expression `ntimes` times waiting an increasing amount of time
#' between tries, i.e. waiting for `Sys.sleep(i * sleep_mult)` seconds between
#' each try. If `expr` fails for `ntimes` times the error will be thrown.
#'
#' @param expr Expression to be evaluated.
#'
#' @param ntimes `integer(1)` with the number of times to try.
#'
#' @param sleep_mult `numeric(1)` multiplier to define the increasing waiting
#'     time.
#'
#' @note
#'
#' Warnings are suppressed.
#'
#' @author Johannes Rainer
#'
#' @importFrom methods is
#'
#' @noRd
.retry <- function(expr, ntimes = 5, sleep_mult = 0) {
    res <- NULL
    for (i in seq_len(ntimes)) {
        res <- suppressWarnings(tryCatch(expr, error = function(e) e))
        if (is(res, "simpleError")) {
            if (i == ntimes)
                stop(res)
            Sys.sleep(i * sleep_mult)
        } else break
    }
    res
}

.sleep_mult <- function() {
    as.integer(getOption("metabolights.sleep_mult", default = 7))
}

# sparse matrices can be passed to `fit_xy()

    Code
      lm_fit <- fit_xy(spec, x = hotel_data[1:100, -1], y = hotel_data[1:100, 1])
    Condition
      Error in `to_sparse_data_frame()`:
      ! `x` is a sparse matrix, but `linear_reg()` with engine `lm` doesn't accept that.

# to_sparse_data_frame() is used correctly

    Code
      fit_xy(spec, x = mtcars[, -1], y = mtcars[, 1])
    Condition
      Error in `to_sparse_data_frame()`:
      ! x is not sparse

---

    Code
      fit_xy(spec, x = hotel_data[, -1], y = hotel_data[, 1])
    Condition
      Error in `to_sparse_data_frame()`:
      ! x is spare, and sparse is not allowed

---

    Code
      fit_xy(spec, x = hotel_data[, -1], y = hotel_data[, 1])
    Condition
      Error in `to_sparse_data_frame()`:
      ! x is spare, and sparse is allowed

# maybe_sparse_matrix() is used correctly

    Code
      fit_xy(spec, x = hotel_data[, -1], y = hotel_data[, 1])
    Condition
      Error in `maybe_sparse_matrix()`:
      ! sparse vectors detected

---

    Code
      fit_xy(spec, x = mtcars[, -1], y = mtcars[, 1])
    Condition
      Error in `maybe_sparse_matrix()`:
      ! no sparse vectors detected

---

    Code
      fit_xy(spec, x = as.data.frame(mtcars)[, -1], y = as.data.frame(mtcars)[, 1])
    Condition
      Error in `maybe_sparse_matrix()`:
      ! no sparse vectors detected

---

    Code
      fit_xy(spec, x = tibble::as_tibble(mtcars)[, -1], y = tibble::as_tibble(mtcars)[,
        1])
    Condition
      Error in `maybe_sparse_matrix()`:
      ! no sparse vectors detected

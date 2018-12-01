# to do
# make file with folders, files etc for new images
# vector for automated saving?

### create seeds vector depending on the number of images
create_seeds <- function(NR_OF_IMG) {
  seeds <- sample(1:10000, NR_OF_IMG)
}

### create file name depening on the date, time and seed
generate_filename <- function(seed) {
  file_name <- paste0(format(Sys.time(), "%Y-%m-%d-%H-%M"), "_seed_", seed, ".png")
}




### check if logfile exists
check_logfile_existence <- function() {
  if (file.exists(LOGFILE_PATH)) {
    print("load logfile")
    logfile <- read_tsv(LOGFILE_PATH)
  } else {
    print("create logfile")
    logfile <- data.frame(file_name = NA, seed = NA)
  }
}

### create the data for the logfile and append it to the existing logfile
generate_logfile <- function(logfile, seed, file_name) {
  logfile_tmp <- data.frame(file_name = file_name, 
                            seed = seed)
  logfile <- bind_rows(logfile, logfile_tmp)
  write_tsv(logfile, LOGFILE_PATH)
  print("logfile saved")
}

### main function that calls all the other functions
generate_img <- function() {
  seeds <- create_seeds(NR_OF_IMG)
  map(seeds, function(seed){
    set.seed(seed)
    file_name <- generate_filename(seed)
    logfile <- check_logfile_existence()
    logfile <- generate_logfile(logfile, seed, file_name)
    df <- generate_data()
    plot <- generate_plot(df, file_name)
  })
}

# recreate images with formula and seed from logfile
get_formula_from_logfile <- function(seed_to_recreate) {
  file_name <- generate_filename(seed_to_recreate)
  logfile_tmp <- check_logfile_existence()
  logfile_tmp <- logfile_tmp %>% filter(seed == seed_to_recreate)
  formula <- list(
    x = parse(text = pull(logfile_tmp, formula_x))[[1]],
    y = parse(text = pull(logfile_tmp, formula_y))[[1]]
  )
}

get_seed_from_logfile <- function(seed_to_recreate) {
  logfile_tmp <- check_logfile_existence()
  seeds <- logfile_tmp %>% filter(seed == seed_to_recreate) %>% pull(seed)
}


### main function that calls all the other functions
regenerate_img <- function(seed_to_recreate, coord) {
  formula <- get_formula_from_logfile(seed_to_recreate)
  seeds <- get_seed_from_logfile(seed_to_recreate)
  print(seeds)
  map(seeds, function(seed){
    set.seed(seed)
    file_name <- generate_filename(seed)
    logfile <- check_logfile_existence()
    logfile <- generate_logfile(logfile, formula, seed, file_name)
    df <- generate_data(formula)
    plot <- generate_plot(df, file_name, coord)
  })
}
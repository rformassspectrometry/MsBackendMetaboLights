# Changelog

## MsBackendMetaboLights 1.3

### Changes in 1.3.2

- Support `backendMerge()` (issue
  [\#10](https://github.com/rformassspectrometry/MsBackendMetaboLights/issues/10)).

### Changes in 1.3.1

- Fix download/sync of files with *BiocFileCache*.

## MsBackendMetaboLights 1.1

### Changes in 1.1.4

- Remove debug message.

### Changes in 1.1.3

- Add
  [`mtbls_delete_cache()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
  to delete locally cached files for a specified MetaboLights ID.
- Change unit tests to only remove selected content instead of wiping
  the full cache.

### Changes in 1.1.2

- Fetch and cache each data file individually.
- Retry retrieval of data from MetaboLights up to 3 times before
  throwing an error message, with an increasing time period between
  attempts.

## MsBackendMetaboLights 1.0

### Changes in 1.0.1

- Complete unit test coverage.

## MsBackendMetaboLights 0.99

### Changes in 0.99.1

- Add
  [`mtbls_sync()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MsBackendMetaboLights.md)
  to synchronize a `MsBackendMetaboLights` object.
- Add
  [`mtbls_sync_data_files()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
  function to cache selected files and
  [`mtbls_cached_data_files()`](https://rformassspectrometry.github.io/MsBackendMetaboLights/reference/MetaboLights-utils.md)
  to list all locally cached data files.

### Changes in 0.99.0

- Prepare package for submission to Bioconductor.

## MsBackendMetabolights 0.0

### Changes in 0.0.3

- Add vignette and `backendMerge,MsBackendMetaboLights` function.

### Changes in 0.0.2

- Add `MsBackendMetaboLights` class, constructor and
  `backendInitalize()` method.

### Changes in 0.0.1

- Add utility functions to retrieve information from MetaboLights.

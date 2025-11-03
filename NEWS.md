# MsBackendMetaboLights 1.5

- Increase number of download retries and increase waiting time in between.

# MsBackendMetaboLights 1.3

## Changes in 1.3.2

- Support `backendMerge()` (issue
  [#10](https://github.com/rformassspectrometry/MsBackendMetaboLights/issues/10)).


## Changes in 1.3.1

- Fix download/sync of files with *BiocFileCache*.

# MsBackendMetaboLights 1.1

## Changes in 1.1.4

- Remove debug message.

## Changes in 1.1.3

- Add `mtbls_delete_cache()` to delete locally cached files for a specified
  MetaboLights ID.
- Change unit tests to only remove selected content instead of wiping the full
  cache.

## Changes in 1.1.2

- Fetch and cache each data file individually.
- Retry retrieval of data from MetaboLights up to 3 times before throwing an
  error message, with an increasing time period between attempts.

# MsBackendMetaboLights 1.0

## Changes in 1.0.1

- Complete unit test coverage.

# MsBackendMetaboLights 0.99

## Changes in 0.99.1

- Add `mtbls_sync()` to synchronize a `MsBackendMetaboLights` object.
- Add `mtbls_sync_data_files()` function to cache selected files and
  `mtbls_cached_data_files()` to list all locally cached data files.

## Changes in 0.99.0

- Prepare package for submission to Bioconductor.

# MsBackendMetabolights 0.0

## Changes in 0.0.3

- Add vignette and `backendMerge,MsBackendMetaboLights` function.

## Changes in 0.0.2

- Add `MsBackendMetaboLights` class, constructor and `backendInitalize()`
  method.

## Changes in 0.0.1

- Add utility functions to retrieve information from MetaboLights.

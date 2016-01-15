# Change Log

## [1.0.1](https://github.com/ndlib/annex-ims/tree/v1.0.1) (2016-01-15)
[Full Changelog](https://github.com/ndlib/annex-ims/compare/v1.0.0...v1.0.1)

**New features/enhancements:**
- Added request description and article title to the "Process Batch" view ([AIMS-336](https://jira.library.nd.edu/browse/AIMS-336), [#130](https://github.com/ndlib/annex-ims/pull/130))
- Requests can now be skipped when processing a batch ([AIMS-263](https://jira.library.nd.edu/browse/AIMS-263), [#134](https://github.com/ndlib/annex-ims/pull/134))
- Started this change log ([AIMS-342](https://jira.library.nd.edu/browse/AIMS-342), [#135](https://github.com/ndlib/annex-ims/pull/135))
- Item/Bin associations will now show on the item detail page [AIMS-340](https://jira.library.nd.edu/browse/AIMS-340)

**Bug fixes:**
- User was unable to fulfill multiple scans for the same item ([AIMS-331](https://jira.library.nd.edu/browse/AIMS-331), [AIMS-332](https://jira.library.nd.edu/browse/AIMS-332), [#129](https://github.com/ndlib/annex-ims/pull/129))
- Users were able to create batches using requests that were skipped in another active batch [AIMS-328](https://jira.library.nd.edu/browse/AIMS-328), [#128](https://github.com/ndlib/annex-ims/pull/128)
- Items that were created in error during ingest have been removed ([AIMS-219](https://jira.library.nd.edu/browse/AIMS-219), [#131](https://github.com/ndlib/annex-ims/pull/131))
- Users should no longer be able to create a new batch if they already have an active batch ([AIMS-329](https://jira.library.nd.edu/browse/AIMS-329), [#133](https://github.com/ndlib/annex-ims/pull/133))
- As a user of the IMS, when I remove the last item from a batch, the batch should be destroyed ([AIMS-339](https://jira.library.nd.edu/browse/AIMS-339), [#132](https://github.com/ndlib/annex-ims/pull/132))

## [1.0.0](https://github.com/ndlib/annex-ims/tree/v1.0.0) (2015-11-11)

**New features/enhancements:**

**Bug fixes:**

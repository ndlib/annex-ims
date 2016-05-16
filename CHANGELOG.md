# Change Log

## [1.3.0](https://github.com/ndlib/annex-ims/tree/v1.3.0) (2016-05-16)
[Full Changelog](https://github.com/ndlib/annex-ims/compare/v1.2.0...v1.3.0)

**New features/enhancements:**
- Users can now click an item from the list of all items in the tray to view detailed information. ([AIMS-129](https://jira.library.nd.edu/browse/AIMS-129),  [#149](https://github.com/ndlib/annex-ims/pull/149))
- Admins can now get to the user permissions view from the main menu ([AIMS-278](https://jira.library.nd.edu/browse/AIMS-278),  [#148](https://github.com/ndlib/annex-ims/pull/148))
- System will no longer allow invalid barcode patterns for items ([AIMS-345](https://jira.library.nd.edu/browse/AIMS-345),  [#147](https://github.com/ndlib/annex-ims/pull/147))

**Bug fixes:**
- Users are no longer able to remove processed requests from an active batch ([AIMS-344](https://jira.library.nd.edu/browse/AIMS-344),  [#150](https://github.com/ndlib/annex-ims/pull/150))

## [1.2.0](https://github.com/ndlib/annex-ims/tree/v1.2.0) (2016-04-01)
[Full Changelog](https://github.com/ndlib/annex-ims/compare/v1.1.0...v1.2.0)

**New features/enhancements:**
- Now allows defining three different types of permissions per user ([AIMS-335](https://jira.library.nd.edu/browse/AIMS-335),  [#145](https://github.com/ndlib/annex-ims/pull/145), [#146](https://github.com/ndlib/annex-ims/pull/146)): 
  - Admin - access to everything
  - Stocking - access only to those options in the Stocking, Items, and Reports menu
  - Review - access only to those options in the Items and Reports menu

**Bug fixes:**
- When a batch is created, then retrieved, and finally processed, it is not finished properly in the system until the user goes back to their active branch and clicks "Done" ([AIMS-343](https://jira.library.nd.edu/browse/AIMS-343),  [#139](https://github.com/ndlib/annex-ims/pull/139))

## [1.1.0](https://github.com/ndlib/annex-ims/tree/v1.1.0) (2016-01-15)
[Full Changelog](https://github.com/ndlib/annex-ims/compare/v1.0.0...v1.1.0)

**New features/enhancements:**
- Added request description and article title to the "Process Batch" view ([AIMS-336](https://jira.library.nd.edu/browse/AIMS-336), [#130](https://github.com/ndlib/annex-ims/pull/130))
- Requests can now be skipped when processing a batch ([AIMS-263](https://jira.library.nd.edu/browse/AIMS-263), [#134](https://github.com/ndlib/annex-ims/pull/134))
- Started this change log ([AIMS-342](https://jira.library.nd.edu/browse/AIMS-342), [#135](https://github.com/ndlib/annex-ims/pull/135))
- Item/Bin associations will now show on the item detail page [AIMS-340](https://jira.library.nd.edu/browse/AIMS-340)

**Bug fixes:**
- User was unable to fulfill multiple scans for the same item ([AIMS-331](https://jira.library.nd.edu/browse/AIMS-331), [AIMS-332](https://jira.library.nd.edu/browse/AIMS-332), [#129](https://github.com/ndlib/annex-ims/pull/129))
- Users were able to create batches using requests that were skipped in another active batch ([AIMS-328](https://jira.library.nd.edu/browse/AIMS-328), [#128](https://github.com/ndlib/annex-ims/pull/128))
- Items that were created in error during ingest have been removed ([AIMS-219](https://jira.library.nd.edu/browse/AIMS-219), [#131](https://github.com/ndlib/annex-ims/pull/131))
- Users should no longer be able to create a new batch if they already have an active batch ([AIMS-329](https://jira.library.nd.edu/browse/AIMS-329), [#133](https://github.com/ndlib/annex-ims/pull/133))
- As a user of the IMS, when I remove the last item from a batch, the batch should be destroyed ([AIMS-339](https://jira.library.nd.edu/browse/AIMS-339), [#132](https://github.com/ndlib/annex-ims/pull/132))

## [1.0.0](https://github.com/ndlib/annex-ims/tree/v1.0.0) (2015-11-11)

**New features/enhancements:**

**Bug fixes:**

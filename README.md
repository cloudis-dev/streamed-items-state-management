![Build](https://github.com/cloudis-dev/streamed-items-state-management/workflows/Build/badge.svg?branch=master)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# Streamed items state management package

State management of items that are received via a stream with updates.
`Added`, `Modified` and `Removed` are the possible updates to the items.

It can also be used for streamed pages of data where all of them will have realtime updates.
There is `PagedStreamsItemsStateNotifier` for this purpose.

All of this is possible with the combination of predefined slivers 
for scroll list view and grid view that can display the `ItemsState`.
These slivers also request more data in case of paginated `ItemsState`.

## Example

There is an [example](./example) that shows the possible usage with an example `ProductModel`.
It uses the [Riverpod](https://pub.dev/packages/riverpod) for the state management.
This example is using just a single stream for receiving products 
(the stream is using mocked data and sending price updates to products with some delays).

In case we need to paginate the data, then the change is really similar 
to the current single stream (single page) example.
The `ProductsStateNotifier` would just need to inherit from the `PagedStreamsItemsStateNotifier`
instead of the `SingleStreamItemsStateNotifier`.


## TODO
- `ItemsStreamHandler` tests
- better logging
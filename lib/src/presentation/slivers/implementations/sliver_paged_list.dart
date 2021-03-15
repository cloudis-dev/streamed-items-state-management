import 'package:flutter/material.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/presentation/slivers/abstraction/paged_scroll_view_base.dart';
import 'package:streamed_items_state_management/src/presentation/utils/scroll_view_error_widget_builder.dart';
import 'package:streamed_items_state_management/src/presentation/utils/scroll_view_item_builder.dart';

class SliverPagedList<T> extends PagedScrollViewBase<T> {
  SliverPagedList({
    Key key,
    int cacheItemsCountExtent,
    @required ItemsState<T> itemsState,
    @required ScrollViewItemBuilder<T> itemBuilder,
    @required void Function() requestData,
    ScrollViewErrorWidgetBuilder errorWidgetBuilder,
    WidgetBuilder loadingWidgetBuilder,
  }) : super(
          cacheItemsCountExtent: cacheItemsCountExtent,
          scrollViewSliverBuilder: (context, delegate) => SliverList(
            delegate: delegate,
          ),
          itemBuilder: itemBuilder,
          itemsState: itemsState,
          requestData: requestData,
          errorWidgetBuilder: errorWidgetBuilder,
          loadingWidgetBuilder: loadingWidgetBuilder,
          key: key,
        );
}

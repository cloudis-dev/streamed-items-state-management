import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:streamed_items_state_management/src/data/items_state.dart';
import 'package:streamed_items_state_management/src/presentation/utils/scroll_view_error_widget_builder.dart';
import 'package:streamed_items_state_management/src/presentation/utils/scroll_view_item_builder.dart';

abstract class PagedScrollViewBase<T> extends StatelessWidget {
  PagedScrollViewBase({
    int cacheItemsCountExtent,
    @required this.scrollViewSliverBuilder,
    @required this.itemBuilder,
    @required this.itemsState,
    @required this.requestData,
    this.errorWidgetBuilder,
    this.loadingWidgetBuilder,
    Key key,
  })  : cacheItemsCountExtent = cacheItemsCountExtent ?? 3,
        super(key: key);

  final Widget Function(
          BuildContext context, SliverChildBuilderDelegate builderDelegate)
      scrollViewSliverBuilder;
  final ScrollViewItemBuilder<T> itemBuilder;
  final ScrollViewErrorWidgetBuilder errorWidgetBuilder;
  final WidgetBuilder loadingWidgetBuilder;

  final ItemsState<T> itemsState;
  final void Function() requestData;

  /// Number of invisible items that trigger a new fetch.
  final int cacheItemsCountExtent;

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        scrollViewSliverBuilder(
          context,
          SliverChildBuilderDelegate(
            (context, index) {
              if (itemsState.status == ItemsStateStatus.waiting &&
                  itemsState.items.length - index < cacheItemsCountExtent) {
                requestData();
              }

              return itemBuilder(context, itemsState.items[index], index);
            },
            childCount: itemsState.items.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Builder(
            builder: (_) {
              switch (itemsState.status) {
                case ItemsStateStatus.loading:
                  return loadingWidgetBuilder == null
                      ? const SizedBox(
                          height: 100,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : loadingWidgetBuilder(context);

                case ItemsStateStatus.error:
                  return errorWidgetBuilder == null
                      ? Column(
                          children: [
                            Icon(Icons.warning),
                            RaisedButton(
                              onPressed: requestData,
                              child: Icon(Icons.refresh),
                            ),
                          ],
                        )
                      : errorWidgetBuilder(context, requestData);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }
}

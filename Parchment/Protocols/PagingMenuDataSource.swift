import Foundation

public protocol PagingMenuDataSource: class {
  func pagingItemBefore(pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem?
  func pagingItemAfter(pagingItem: PagingItem, isGenerateLayout: Bool) -> PagingItem?
}

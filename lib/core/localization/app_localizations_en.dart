// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Matrix Palestine';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonNoInternet => 'No internet connection';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again';

  @override
  String get commonEmptyTitle => 'No data';

  @override
  String get commonCurrency => '₪';

  @override
  String get commonOnline => 'Online';

  @override
  String get commonOffline => 'Offline';

  @override
  String get commonLogout => 'Logout';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonClose => 'Close';

  @override
  String get commonShare => 'Share';

  @override
  String get commonPrint => 'Print';

  @override
  String get commonView => 'View';

  @override
  String get commonCall => 'Call';

  @override
  String get commonFrom => 'From';

  @override
  String get commonTo => 'To';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonNotes => 'Notes';

  @override
  String get navHome => 'Home';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navSales => 'Sales';

  @override
  String get navCollections => 'Collections';

  @override
  String get navMore => 'More';

  @override
  String get navStock => 'Stock';

  @override
  String get navDocuments => 'Documents';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Enter your details to continue';

  @override
  String get loginUsername => 'Username / Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginSubmit => 'Login';

  @override
  String get loginBiometric => 'Login with biometrics';

  @override
  String get loginBiometricFailed =>
      'Fingerprint verification failed. Please try again.';

  @override
  String get loginValidationRequired => 'This field is required';

  @override
  String get loginFailedTitle => 'Login failed';

  @override
  String get moreProfile => 'Profile';

  @override
  String get moreLanguage => 'Language';

  @override
  String get moreLanguageArabic => 'العربية';

  @override
  String get moreLanguageEnglish => 'English';

  @override
  String get moreLogoutConfirm => 'Do you want to logout?';

  @override
  String get dashboardGoodMorning => 'Good Morning';

  @override
  String get dashboardGoodAfternoon => 'Good Afternoon';

  @override
  String get dashboardGoodEvening => 'Good Evening';

  @override
  String get dashboardTodaySales => 'Today\'s Sales';

  @override
  String get dashboardCollections => 'Collections';

  @override
  String get dashboardReceivables => 'Receivables';

  @override
  String get dashboardTodayInvoices => 'Today\'s Invoices';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardNewSale => 'New Sale';

  @override
  String get dashboardCollectPayment => 'Collect Payment';

  @override
  String get dashboardReturn => 'Return';

  @override
  String get dashboardMyStock => 'My Stock';

  @override
  String get dashboardCustomers => 'Customers';

  @override
  String get dashboardProducts => 'Products';

  @override
  String get dashboardTotalProducts => 'Total Products';

  @override
  String get dashboardLowStock => 'Low Stock';

  @override
  String get dashboardTodayReceipts => 'Today\'s Receipts';

  @override
  String get dashboardTodayIssues => 'Today\'s Issues';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions waiting for sync',
      one: '1 transaction waiting for sync',
    );
    return '$_temp0';
  }

  @override
  String get syncedUpToDate => 'Synced';

  @override
  String get productFoundTitle => 'Product Found';

  @override
  String get productNotFoundTitle => 'Product not found';

  @override
  String get productAvailable => 'Available';

  @override
  String get productSellingPrice => 'Selling Price';

  @override
  String get productAddToInvoice => 'Add to Invoice';

  @override
  String get productSearchHint => 'Search product';

  @override
  String get productScanBarcode => 'Scan Barcode';

  @override
  String get productScanInstruction => 'Point the camera at the barcode';

  @override
  String get productsEmpty => 'No products';

  @override
  String get productNewProduct => 'New Product';

  @override
  String get productBarcode => 'Barcode';

  @override
  String get productCategory => 'Category';

  @override
  String get productAddCategory => 'Add New Category';

  @override
  String get productBrand => 'Brand';

  @override
  String get productAddBrand => 'Add New Brand';

  @override
  String get productBaseUnit => 'Base Unit';

  @override
  String get productAddUnit => 'Add New Unit';

  @override
  String get productUnitSymbol => 'Symbol (e.g. PC)';

  @override
  String get productReorderLevel => 'Reorder Level';

  @override
  String get productAddBulkUnit => 'Add a larger sale unit (e.g. carton)';

  @override
  String get productBulkUnit => 'Larger Unit';

  @override
  String get productBulkConversion => 'Base units inside it';

  @override
  String get productAddOpeningStock => 'Add opening stock';

  @override
  String get productOpeningQuantity => 'Opening Quantity';

  @override
  String get productSave => 'Save Product';

  @override
  String get productValidationRequired =>
      'English name, Arabic name, base unit, and selling price are all required';

  @override
  String get customerBalance => 'Balance';

  @override
  String get customerCreditLimit => 'Credit Limit';

  @override
  String get customerNewSale => 'New Sale';

  @override
  String get customerPayment => 'Payment';

  @override
  String get customerStatement => 'Statement';

  @override
  String get customerCall => 'Call';

  @override
  String get customerSearchHint => 'Name, phone, code, area';

  @override
  String get customersEmpty => 'No customers';

  @override
  String get customerTabOverview => 'Overview';

  @override
  String get customerTabSales => 'Sales';

  @override
  String get customerTabPayments => 'Payments';

  @override
  String get customerTabStatement => 'Statement';

  @override
  String get customerAvailableCredit => 'Available Credit';

  @override
  String get customerOpeningBalance => 'Opening Balance';

  @override
  String get customerClosingBalance => 'Current Balance';

  @override
  String get customerNoPhone => 'No phone number';

  @override
  String get customerNewCustomer => 'New Customer';

  @override
  String get customerFieldName => 'Name (English)';

  @override
  String get customerFieldNameAr => 'Name (Arabic)';

  @override
  String get customerFieldPhone => 'Phone';

  @override
  String get customerFieldSecondaryPhone => 'Secondary Phone';

  @override
  String get customerFieldArea => 'Area';

  @override
  String get customerFieldCity => 'City';

  @override
  String get customerFieldAddress => 'Address';

  @override
  String get customerFieldCreditLimit => 'Credit Limit';

  @override
  String get customerFieldPaymentTerms => 'Payment Terms (days)';

  @override
  String get customerSave => 'Save Customer';

  @override
  String get customerCreatedTitle => 'Customer Added';

  @override
  String get customerNameRequired =>
      'Both the English and Arabic name are required';

  @override
  String get saleSelectCustomer => 'Select Customer';

  @override
  String get saleSearchCustomer => 'Search customer...';

  @override
  String get saleAddProducts => 'Add Products';

  @override
  String get saleCart => 'Cart';

  @override
  String get saleCartEmpty => 'Cart is empty';

  @override
  String get saleQuantity => 'Quantity';

  @override
  String get salePrice => 'Price';

  @override
  String get saleTotal => 'Total';

  @override
  String get saleSubtotal => 'Subtotal';

  @override
  String get saleDiscount => 'Discount';

  @override
  String get salePaid => 'Paid';

  @override
  String get saleRemaining => 'Remaining';

  @override
  String get salePaymentMethod => 'Payment Method';

  @override
  String get salePaymentCash => 'Cash';

  @override
  String get salePaymentBankTransfer => 'Bank Transfer';

  @override
  String get salePaymentCheque => 'Cheque';

  @override
  String get salePaymentCredit => 'Credit';

  @override
  String get salePaymentPartial => 'Partial';

  @override
  String get saleConfirm => 'Confirm Sale';

  @override
  String get saleReview => 'Review Invoice';

  @override
  String get saleCompletedTitle => 'Sale Completed';

  @override
  String get saleInvoiceNumber => 'Invoice #';

  @override
  String get saleViewInvoice => 'View Invoice';

  @override
  String get saleNewSale => 'New Sale';

  @override
  String get saleSharePdf => 'Share PDF';

  @override
  String get salesEmpty => 'No invoices';

  @override
  String get saleStatusConfirmed => 'Confirmed';

  @override
  String get saleStatusCancelled => 'Cancelled';

  @override
  String get saleNextStep => 'Next';

  @override
  String get saleBackStep => 'Back';

  @override
  String get saleMustSelectCustomer => 'Please select a customer';

  @override
  String get saleMustAddProduct => 'Please add at least one product';

  @override
  String get paymentCurrentBalance => 'Current Balance';

  @override
  String get paymentAmount => 'Payment Amount';

  @override
  String get paymentReference => 'Reference';

  @override
  String get paymentConfirm => 'Confirm Payment';

  @override
  String get paymentRecordedTitle => 'Payment Recorded';

  @override
  String get paymentPreviousBalance => 'Previous Balance';

  @override
  String get paymentNewBalance => 'New Balance';

  @override
  String get paymentsEmpty => 'No payments';

  @override
  String get paymentSelectCustomerFirst => 'Please select a customer first';

  @override
  String get stockAvailable => 'Available Quantity';

  @override
  String get stockLowBadge => 'Low';

  @override
  String get stockEmpty => 'No stock data';

  @override
  String get moreVersion => 'Version';

  @override
  String get returnSelectInvoice => 'Select Invoice';

  @override
  String get returnSelectProducts => 'Select Returned Products';

  @override
  String get returnQuantity => 'Return Quantity';

  @override
  String get returnMaxReturnable => 'Max returnable';

  @override
  String get returnConfirm => 'Confirm Return';

  @override
  String get returnCompletedTitle => 'Return Recorded';

  @override
  String get returnsEmpty => 'No returns';

  @override
  String get returnNumber => 'Return #';

  @override
  String get returnNewReturn => 'New Return';

  @override
  String get vehicleLoadNewTitle => 'New Vehicle Load';

  @override
  String get vehicleLoadSelectVehicle => 'Select Vehicle';

  @override
  String get vehicleLoadSelectRep => 'Select Sales Rep';

  @override
  String get vehicleLoadSelectWarehouse => 'Select Warehouse';

  @override
  String get vehicleLoadAddProduct => 'Add Product';

  @override
  String get vehicleLoadConfirm => 'Confirm Loading';

  @override
  String get vehicleLoadCompletedTitle => 'Vehicle Loaded';

  @override
  String get vehicleLoadsEmpty => 'No vehicle loads';

  @override
  String get vehicleLoadNumber => 'Load #';

  @override
  String get vehicleLoadStatusLoaded => 'Loaded';

  @override
  String get vehicleLoadStatusSettled => 'Settled';

  @override
  String get myVehicleStockTitle => 'My Vehicle Stock';

  @override
  String get myVehicleStockNoTrip => 'No open trip right now';

  @override
  String get myVehicleStockLoaded => 'Loaded';

  @override
  String get myVehicleStockSold => 'Sold';

  @override
  String get myVehicleStockReturned => 'Returned';

  @override
  String get myVehicleStockRemaining => 'Remaining';

  @override
  String get myVehicleStockSettle => 'End of Day Settlement';

  @override
  String get settlementTitle => 'Daily Settlement';

  @override
  String get settlementExpected => 'Expected';

  @override
  String get settlementActual => 'Actual (physical count)';

  @override
  String get settlementDifference => 'Difference';

  @override
  String get settlementReasonHint => 'Reason for difference (optional)';

  @override
  String get settlementSubmit => 'Submit Settlement';

  @override
  String get settlementSubmittedTitle => 'Settlement Submitted';

  @override
  String get settlementStatusNoDiscrepancy => 'No Discrepancy';

  @override
  String get settlementStatusPending => 'Pending Approval';

  @override
  String get settlementStatusApproved => 'Approved';

  @override
  String get settlementApprove => 'Approve Settlement';

  @override
  String get settlementsEmpty => 'No settlements';

  @override
  String get settlementApproved => 'Settlement approved';

  @override
  String get purchaseNewTitle => 'New Purchase Invoice';

  @override
  String get purchaseSelectSupplier => 'Select Supplier';

  @override
  String get purchaseUnitCost => 'Unit Cost';

  @override
  String get purchaseConfirm => 'Confirm Purchase';

  @override
  String get purchasesEmpty => 'No purchase invoices';

  @override
  String get purchaseNumber => 'Purchase #';

  @override
  String get transferNewTitle => 'New Stock Transfer';

  @override
  String get transferFromWarehouse => 'From Warehouse';

  @override
  String get transferToWarehouse => 'To Warehouse';

  @override
  String get transferConfirm => 'Confirm Transfer';

  @override
  String get transfersEmpty => 'No transfers';

  @override
  String get adjustmentNewTitle => 'Stock Adjustment';

  @override
  String get adjustmentQuantityChange => 'Quantity Change';

  @override
  String get adjustmentReason => 'Reason';

  @override
  String get adjustmentConfirm => 'Confirm Adjustment';

  @override
  String get warehouseDocumentsTitle => 'Documents';

  @override
  String get movementsEmpty => 'No stock movements';

  @override
  String get syncStatusTitle => 'Sync Status';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncNoPending => 'No transactions waiting for sync';

  @override
  String get syncFailedBadge => 'Failed';

  @override
  String get syncPendingBadge => 'Waiting for sync';

  @override
  String get syncRetry => 'Retry';

  @override
  String get syncQueuedOffline =>
      'Saved locally — will be sent once you\'re back online';

  @override
  String get syncCompleted => 'Sync completed';

  @override
  String get syncTypeSale => 'Sale';

  @override
  String get syncTypePayment => 'Payment';

  @override
  String get syncTypeReturn => 'Return';

  @override
  String get moreReports => 'Reports';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsSales => 'Sales';

  @override
  String get reportsCollections => 'Collections';

  @override
  String get reportsReceivables => 'Receivables';

  @override
  String get reportsInventory => 'Inventory';

  @override
  String get reportsProfit => 'Profit';

  @override
  String get reportsSalesSubtitle =>
      'Today\'s sales, by date, product, customer or rep';

  @override
  String get reportsCollectionsSubtitle =>
      'Today\'s collections, by rep or customer';

  @override
  String get reportsReceivablesSubtitle =>
      'Aging buckets and customer balances';

  @override
  String get reportsInventorySubtitle =>
      'Current stock, low stock and stock movement';

  @override
  String get reportsProfitSubtitle => 'Revenue, cost, gross profit and margin';

  @override
  String get reportFrom => 'From';

  @override
  String get reportTo => 'To';

  @override
  String get reportGroupBy => 'Group by';

  @override
  String get reportGroupByNone => 'Total';

  @override
  String get reportGroupByDate => 'Date';

  @override
  String get reportGroupByProduct => 'Product';

  @override
  String get reportGroupByCustomer => 'Customer';

  @override
  String get reportGroupByRepresentative => 'Representative';

  @override
  String get reportInvoiceCount => 'Invoices';

  @override
  String get reportPaymentCount => 'Payments';

  @override
  String get reportTotal => 'Total';

  @override
  String get reportNoData => 'No data for this period';

  @override
  String get reportExportPdf => 'Export PDF';

  @override
  String get profitRevenue => 'Revenue';

  @override
  String get profitCost => 'Cost';

  @override
  String get profitGrossProfit => 'Gross Profit';

  @override
  String get profitMargin => 'Margin';

  @override
  String get receivablesCurrent => 'Current';

  @override
  String get receivablesDays1to30 => '1–30 Days';

  @override
  String get receivablesDays31to60 => '31–60 Days';

  @override
  String get receivablesDays61to90 => '61–90 Days';

  @override
  String get receivablesOver90 => '90+ Days';

  @override
  String get receivablesTotal => 'Total';

  @override
  String get receivablesCustomers => 'Customer Balances';

  @override
  String get receivablesEmpty => 'No outstanding receivables';

  @override
  String get movementsTitle => 'Stock Movement';

  @override
  String get movementTypeAll => 'All Types';

  @override
  String get movementTypePurchase => 'Purchase';

  @override
  String get movementTypeSale => 'Sale';

  @override
  String get movementTypeReturn => 'Return';

  @override
  String get movementTypeAdjustment => 'Adjustment';

  @override
  String get movementTypeTransfer => 'Transfer';

  @override
  String get movementTypeVehicleLoad => 'Vehicle Load';

  @override
  String get movementTypeVehicleReturn => 'Vehicle Return';

  @override
  String get stockLowStockOnly => 'Low stock only';
}

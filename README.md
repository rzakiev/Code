## Code

### Introduction

Compound is a Swift-based iOS app that was originally developed for a small group of private investors from St.Petersburg. The app catalogues a list of publicly traded Russian companies along with their financial indicators and market valuations. The main objective of the app is to provide a clear overview of a particular company’s financial health by displaying its revenue, profit,  and debt load figures, among others.

The app is built using the MVC model, with a total of four Table View Controllers displaying data and one root TabBar Controller providing the navigation between two main table view controllers.

### Companies’ Financial Figures

The first main table view controller (StockListTableViewController) displays the list of examined companies. Tapping on a particular company will transition the view to the StockViewTableViewController that outlines a detailed overview of the company’s financial and production figures over the last five years. The first section contains the following financial data:

* Revenue growth
* Operating Income growth
* Net Profit Growth
* Dividend Growth
* Leverage 

The second section contains the following multipliers:

* Market Capitalization (calculated asynchronously)
* Earnings divided by market capitalization
* The dividend yield (calculated asynchronously))

The third section of the table contains production figures for the selected company (if available).

### Portfolio

The second main table view controller displays the user’s portfolio. It’s empty by default; however, the user can manually add a new holding by tapping on the **+** button in the upper right-hand corner. From there, the user can specify the company of the recently purchased stake, the number of shares, and the purchase price. Tapping **Done** will save the holding and add it to portfolio. The portfolio view also displays the market price of all the holdings in the portfolio and therefore enables investors to track their performance relative to the market.

Please note that the app mandates biometric authentication on launch and cannot be disabled.

import lua.Table;
import RequestHelper;
import JsonHelper;
import Coinstats;

enum abstract AccountType(String) {
	var AccountTypeGiro = "AccountTypeGiro";
	var AccountTypeSavings = "AccountTypeSavings";
	var AccountTypeFixedTermDeposit = "AccountTypeFixedTermDeposit";
	var AccountTypeLoan = "AccountTypeLoan";
	var AccountTypeCreditCard = "AccountTypeCreditCard";
	var AccountTypePortfolio = "AccountTypePortfolio";
	var AccountTypeOther = "AccountTypeOther";
}

typedef Account = {
	?name:String,
	?owner:String,
	?accountNumber:String,
	?subAccount:String,
	?portfolio:Bool,
	?bankCode:String,
	?currency:String,
	?iban:String,
	?bic:String,
	?balance:Float,
	type:AccountType
}

typedef Transaction = {
	?name:String,
	?accountNumber:String,
	?bankCode:String,
	?amount:Float,
	?currency:String,
	?bookingDate:Int,
	?valueDate:Int,
	?purpose:String,
	?transactionCode:Int,
	?textKeyExtension:Int,
	?purposeCode:String,
	?bookingKey:String,
	?bookingText:String,
	?primanotaNumber:String,
	?batchReference:String,
	?endToEndReference:String,
	?mandateReference:String,
	?creditorId:String,
	?returnReason:String,
	?booked:Bool
}

typedef Security = {
	?name:String,
	?isin:String,
	?securityNumber:String,
	?quantity:Float,
	?currencyOfQuantity:String,
	?purchasePrice:Float,
	?currencyOfPurchasePrice:String,
	?exchangeRateOfPurchasePrice:Float,
	?price:Float,
	?currencyOfPrice:String,
	?exchangeRateOfPrice:Float,
	?amount:Float,
	?originalAmount:Float,
	?currencyOfOriginalAmount:String,
	?market:String,
	?tradeTimestamp:Int
}

class Main {
	@:expose("dosomething")
	static function dosomething() {
		trace("dosomething dosomething");
	}

	@:luaDotMethod
	@:expose("SupportsBank")
	static function SupportsBank(protocol:String, bankCode:String) {
		trace("SupportsBank got called");
		trace(protocol);
		trace(bankCode);

		return bankCode == "Coinstats";
	}

	@:luaDotMethod
	@:expose("InitializeSession")
	static function InitializeSession(protocol:String, bankCode:String, username:String, reserved, password:String): Dynamic {
		trace("InitializeSession got called");
		trace(protocol);
		trace(bankCode);
		trace(username);
		trace(reserved);
		trace(password);


		trace("calling /me");
		var me = Coinstats.getUserInfo(password);
		if (me.message != null && me.message == "session not found.") {
			trace("is unauthorized");
			return untyped __lua__("LoginFailed");
			return "Unauthorized, session may have expired";
		}
		trace("me response:");
		trace(me);
		Storage.set("token", password);

		return true;
	}

	@:luaDotMethod
	@:expose("ListAccounts")
	static function ListAccounts(knownAccounts) {
		trace("ListAccounts got called");
		trace(knownAccounts);

		var token = Storage.get("token");

		var me = Coinstats.getUserInfo(token);
		var portfolio = Coinstats.getPortfolioItems(token);

		var current_hour = Date.now().getHours();
		var cache_key = "portfolio_response_" + current_hour;
		Storage.set(cache_key, JsonHelper.stringify(portfolio));

		var accounts:Array<Account> = [];
		for (portfolioItem in portfolio) {
			var name = portfolioItem.n;
			var id = portfolioItem.i;
			trace("processing: " + portfolioItem.n);

			var acc:Account = {
				name: "Coinstats " + name,
				accountNumber: id,
				currency: "USD",
				type: AccountType.AccountTypePortfolio,
				portfolio: true,
			}

			accounts.push(acc);
		}

		return Table.fromArray(accounts);

		// var account:Account = {
		// 	name: "Coinstats " + me.username,
		// 	accountNumber: me.email,
		// 	currency: "USD",
		// 	type: AccountType.AccountTypePortfolio,
		// 	portfolio: true,
		// };

		// var results = Table.fromArray([account]);
		// return results;
	}

	@:luaDotMethod
	@:expose("RefreshAccount")
	static function RefreshAccount(account:{
		iban:String,
		bic:String,
		comment:String,
		bankCode:String,
		owner:String,
		attributes:Dynamic,
		subAccount:String,
		currency:String,
		name:String,
		balance:Float,
		portfolio:Bool,
		type:String,
		balanceDate:Float,
		accountNumber:String
	}, since:Float) {
		trace("RefreshAccount got called");
		trace(account);
		trace(since);

		var token = Storage.get("token");

		var current_hour = Date.now().getHours();
		var cache_key = "portfolio_response_" + current_hour;

		var portfolio = Storage.get(cache_key);
		trace("got portfolio ---- " + cast portfolio);
		// if (portfolio == null) {
		portfolio = Coinstats.getPortfolioItems(token);
		trace("got portfolio 2 ---- " + JsonHelper.stringify(portfolio));
		Storage.set(cache_key, JsonHelper.stringify(portfolio));
		// } else {
		// 	portfolio = JsonHelper.parse(cast portfolio);
		// }

		var aggregatedCoins = new Map<String, Float>();
		var aggregatedCoinInfo = new Map<String, CoinInfo>();

		var curPortfolioValue = 0.0;

		for (portfolioItem in portfolio) {
			if (portfolioItem.i != account.accountNumber) {
				continue;
			}
			trace("processing: " + portfolioItem.cn);
			var portfolioContent = portfolioItem.pi;
			curPortfolioValue = portfolioItem.p.USD;

			for (content in Table.toArray(cast portfolioContent)) {
				var amount = content.c;
				var coinInfo = content.coin;
				var symbol = coinInfo.s;

				trace("Processing coin: " + coinInfo.i + " - " + Std.string(content.ab.all.USD) + " amount: " + Std.string(amount));
				trace(coinInfo);
				trace(content);

				if (amount == 0) {
					continue;
				}

				if (aggregatedCoins.exists(symbol)) {
					var currentAmount = aggregatedCoins.get(symbol);
					aggregatedCoins.set(symbol, currentAmount + amount);

					var existingCoinInfo = aggregatedCoinInfo.get(symbol);
					if (existingCoinInfo.avgPurchasePrice < content.ab.all.USD) {
						existingCoinInfo.avgPurchasePrice = content.ab.all.USD;
						aggregatedCoinInfo.set(symbol, existingCoinInfo);
					}
				} else {
					trace("No portfolio content for: " + portfolioItem.cn);
					aggregatedCoins.set(symbol, amount);

					var convertedCoinInfo:CoinInfo = {
						id: coinInfo.i,
						symbol: symbol,
						name: coinInfo.n,
						price: coinInfo.pu,
						avgPurchasePrice: content.ab.all.USD,
					}

					aggregatedCoinInfo.set(symbol, convertedCoinInfo);
				}
			}
		}

		trace(aggregatedCoins);
		trace(aggregatedCoinInfo);

		// convert to securities
		var securities = new Array<Security>();
		for (symbol in aggregatedCoins.keys()) {
			var amount = aggregatedCoins.get(symbol);
			var coinInfo = aggregatedCoinInfo.get(symbol);
			var security:Security = {
				name: coinInfo.symbol + " (" + coinInfo.name + ")",
				isin: coinInfo.symbol,
				quantity: amount,
				// currencyOfQuantity: coinInfo.symbol,
				purchasePrice: coinInfo.avgPurchasePrice,
				// currencyofPurchasePrice: coinInfo.symbol,
				price: coinInfo.price,
				currencyOfPrice: "USD"
			}

			securities.push(security);
		}

		trace(securities);
		trace(curPortfolioValue);

		return {
			balance: curPortfolioValue,
			securities: Table.fromArray(securities),
		}
	}

	@:luaDotMethod
	@:expose("EndSession")
	static function EndSession() {
		trace("EndSession got called");
	}

	function nonstatic() {
		trace("ooooo");
	}

	static function main() {
		untyped __lua__("
        WebBanking {
            version = 1.0,
            url = 'https://coinstats.app',
            description = 'Coinstats',
            services = { 'Coinstats' },
        }
        ");

		untyped __lua__("
        function SupportsBank(protocol, bankCode)
            return _hx_exports.SupportsBank(protocol, bankCode)
        end
        ");

		untyped __lua__("
        function InitializeSession(protocol, bankCode, username, reserved, password)
            return _hx_exports.InitializeSession(protocol, bankCode, username, reserved, password)
        end
        ");

		untyped __lua__("
        function RefreshAccount(account, since)
            return _hx_exports.RefreshAccount(account, since)
        end
        ");

		untyped __lua__("
        function ListAccounts(knownAccounts)
            return _hx_exports.ListAccounts(knownAccounts)
        end
        ");

		untyped __lua__("
        function EndSession()
            return _hx_exports.EndSession()
        end
        ");
	}
}

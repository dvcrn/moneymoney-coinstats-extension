import lua.Table;
import RequestHelper;
import JsonHelper;

typedef PortfolioItem = {
	on:Bool,
	i:String,
	n:String,
	vt:String,
	fd:String,
	o:Int,
	at:Int,
	ai:Dynamic,
	tne:Bool,
	ss:Int,
	cnn:{
		id:String, type:String
	},
	cn:String,
	sbl:Bool,
	pi:Array<{
		i:String,
		coin:{
			i:String,
			s:String,
			n:String,
			ic:String,
			p24:Float,
			r:Int,
			p1:Float,
			p7:Float,
			v:Float,
			mc:Float,
			pb:Float,
			pu:Float
		},
		p:{
			USD:Float,
			BTC:Float,
			ETH:Float
		},
		pp:{
			all:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			h24:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			lt:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			ch:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			r:Dynamic
		},
		c:Float,
		pt:{
			all:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			h24:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			lt:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			ch:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			r:Dynamic
		},
		ab:{
			all:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			ch:{
				USD:Float,
				BTC:Float,
				ETH:Float
			},
			lt:{
				USD:Float,
				BTC:Float,
				ETH:Float
			}
		},
		as:{
			all:{
				USD:Float,
				BTC:Float,
				ETH:Float
			}
		}
	}>,
	pp:Dynamic,
	p:Dynamic,
	pdt:Dynamic,
	dp:{
		USD:Float, BTC:Float, ETH:Float
	},
	pt:Dynamic,
	bp:Dynamic,
	tpl:{
		pp:{
			ch:Dynamic, r:Dynamic, all:Dynamic
		}, pt:{
			ch:Dynamic, r:Dynamic, all:Dynamic
		}, tc:Dynamic
	},
	hcc:Int,
	hdefi:Bool,
	hdiscover:Bool,
	verified:Bool,
	hnft:Bool,
	sub:Array<Dynamic>,
	wcv1:Bool,
	supd:Bool,
	vca:Bool,
	supea:Bool,
	web3:Array<String>,
	mchw:Bool
}

typedef CoinInfo = {
	id:String,
	symbol:String,
	name:String,
	price:Float,
	avgPurchasePrice:Float,
}

class Coinstats {
	public static function getPortfolioItems(token:String):Array<PortfolioItem> {
		var url = "https://api.coin-stats.com/v7/portfolio_items?visibility=personal&coinExtraData=true&showAverage=true";
		var method = "GET";
		var headers = [
			"Accept" => "application/json, text/plain, */*",
			"Sec-Fetch-Site" => "cross-site",
			"If-None-Match" => "W/\"35ffe-GL0G2XZ/cy+IwWKyySXo9DqOePs\"",
			"Accept-Language" => "en-US,en;q=0.9",
			"Sec-Fetch-Mode" => "cors",
			"Origin" => "https://coinstats.app",
			"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15",
			"Referer" => "https://coinstats.app/",
			"Accept-Encoding" => "gzip, deflate, br",
			"Sec-Fetch-Dest" => "empty",
			"x-app-appearance" => "light",
			"Priority" => "u=3, i",
			"platform" => "web",
			"token" => token,
			"x-language-code" => "en"
		];

		var response = RequestHelper.makeRequest(url, method, headers);
		var parsed = JsonHelper.parse(response.content);
		return Table.toArray(parsed);
	}

	public static function getUserInfo(token:String):{
		hasUnlimitedAccess:Bool,
		username:String,
		email:String,
		displayName:String,
		subCancelledDate:String,
		emailVerified:Bool,
		emailVerificationSent:Bool,
		createdAt:String,
		isSocial:Bool,
		userId:String,
		stripeDataPlan:String,
		customerId:String,
		emailStatus:String,
		message:String,
		unlimitedSource:String,
		hideSmallBalances:Bool,
		calcDefiOnTotal:Bool,
		hideUnidentifiedBalances:Bool,
		significantChangeNotificationsDisabled:Bool,
		breakingNewsNotificationsDisabled:Bool,
		calcTransfersInPL:Bool,
		accountType:String,
		referralLink:String,
		limits:{
			fields:Array<Dynamic>,
			status:String,
			isActive:Bool,
			upgradedType:String,
			upgradedCount:Int
		}
	} {
		var url = "https://api.coin-stats.com/v3/me";
		var method = "GET";
		var headers = [
			"Accept" => "application/json, text/plain, */*",
			"Sec-Fetch-Site" => "cross-site",
			"Accept-Language" => "en-US,en;q=0.9",
			"If-None-Match" => "W/\"366-Y78rqL8rJ4PtAp09Re7W6dYhbdw\"",
			"Sec-Fetch-Mode" => "cors",
			"Origin" => "https://coinstats.app",
			"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15",
			"Referer" => "https://coinstats.app/",
			"Accept-Encoding" => "gzip, deflate, br",
			"Sec-Fetch-Dest" => "empty",
			"Priority" => "u=3, i",
			"platform" => "web",
			"token" => token
		];

		var response = RequestHelper.makeRequest(url, method, headers);
		var parsed = JsonHelper.parse(response.content);
		return parsed;
	}
}

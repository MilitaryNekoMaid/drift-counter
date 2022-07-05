Config = {

Payout = {
	Enable = true, -- Enables payouts from drifting.
	Divider = 100, -- This number will be divided by score and result will be paid.
},

Logging = {
	Enable = true, -- Enables discord logging.
	Webhook = "webhook_url", -- Discord webhook url.
},

Notification = {
	Enable = true, -- Enables notifications.
	Message = 'You obtained $%s from drifting.' -- Notification message after you finish drift.
}

}

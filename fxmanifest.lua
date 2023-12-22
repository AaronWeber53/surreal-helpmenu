fx_version 'adamant'

game 'gta5'

ui_page 'html/index.html'

server_script {
	'server.lua',
	'@oxmysql/lib/MySQL.lua',
}

client_script {
	'client.lua'
}

files {
	'html/index.html',
	'html/assets/css/*.css',
	'html/assets/js/*.js',
	'html/assets/images/*.png',
	'html/pages/*.html'
}

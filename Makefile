git:
	git add .
	date -u +%Y%m%d-%H:%M:%S > commit.txt
	git commit -a -Fcommit.txt --no-edit
	git pull
	git push -u origin master
	exit

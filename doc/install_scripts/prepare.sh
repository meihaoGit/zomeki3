#!/bin/bash

INSTALL_SCRIPTS_URL='https://raw.githubusercontent.com/zomeki/zomeki3/master/doc/install_scripts'

echo '#### Prepare to install ####'

centos() {
  echo "It's CentOS!"

  yum -y install git

  cd /usr/local/src

  files=('install_ruby.sh' 'install_nginx.rb' 'install_postgresql.rb' 'install_zomeki.sh'
         'configure_zomeki.rb' 'install_zomeki_kana_read.sh' 'start_servers.sh' 'install_cron.sh')

  rm -f install_scripts.txt install_all.sh
  for file in ${files[@]}; do
    echo "$INSTALL_SCRIPTS_URL/$file" >> install_scripts.txt
    echo "./$file" >> install_all.sh
    curl -fsSLO "$INSTALL_SCRIPTS_URL/$file"
    chmod 755 $file
  done

cat <<'EOF' > install_all.sh

echo "
-- インストールを完了しました。 --

  公開画面: `ruby -ryaml -e "puts YAML.load_file('/var/share/zomeki/config/core.yml')['production']['uri']"`

  管理画面: `ruby -ryaml -e "puts YAML.load_file('/var/share/zomeki/config/core.yml')['production']['uri']"`_system

    管理者（システム管理者）
    ユーザID   : zomeki
    パスワード : zomeki

２．PostgreSQLのzomekiユーザはパスワードがzomekipassに設定されています。適宜変更してください。
    mysql> SET PASSWORD FOR zomeki@localhost = PASSWORD('newpass');
    また、変更時には /var/share/zomeki/config/database.yml も合わせて変更してください。
    # vi /var/share/zomeki/config/database.yml
３．OS の zomeki ユーザに cron が登録されています。
    # crontab -u zomeki -e
"
EOF
  chmod 755 install_all.sh

echo '
-- インストールを続けるには以下のコマンドを実行してください。 --

# cd /usr/local/src && /usr/local/src/install_all.sh
'
}

others() {
  echo 'This OS is not supported.'
}

if [ -f /etc/centos-release ]; then
  centos
elif [ -f /etc/lsb-release ]; then
  if grep -qs Ubuntu /etc/lsb-release; then
    echo 'Ubuntu is not yet supported.'
  else
    others
  fi
else
  others
fi

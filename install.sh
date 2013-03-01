echo "cookbook_path \"`pwd`\"" > solo.rb
if [ "$http_proxy" != "" ]; then
  echo "http_proxy \"$http_proxy\"" >> solo.rb
fi
if [ "$https_proxy" != "" ]; then
  echo "https_proxy \"$http_proxy\"" >> solo.rb
fi


/usr/bin/chef-solo -j ./chef.json -c ./solo.rb

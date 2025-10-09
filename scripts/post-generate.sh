#!/bin/bash

echo "Applying post-generation modifications..."

# Fix JSON.decode to Jason.decode in deserializer.ex
sed -i.bak 's/JSON\.decode/Jason.decode/g' lib/sdkapi/deserializer.ex

# Add function clause for already decoded maps
sed -i.bak 's/def json_decode(json) do/def json_decode(json) when is_binary(json) do/' lib/sdkapi/deserializer.ex

# Add the new function clause using a simple approach
cp lib/sdkapi/deserializer.ex lib/sdkapi/deserializer.ex.tmp
awk '
/def json_decode\(json\) when is_binary\(json\) do/ {
  print
  getline
  print
  print ""
  print "  def json_decode(data) when is_map(data) do"
  print "    {:ok, data}"
  print "  end"
  next
}
{ print }
' lib/sdkapi/deserializer.ex.tmp > lib/sdkapi/deserializer.ex
rm -f lib/sdkapi/deserializer.ex.tmp

# Clean up backup files
rm -f lib/sdkapi/*.bak lib/sdkapi/**/*.bak

echo "Post-generation modifications applied!"

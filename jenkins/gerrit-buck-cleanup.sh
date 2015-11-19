set +x
ORPHAN_BUCK_PIDS=$(ps -o pid,command -e | grep -i java | grep -i buck | grep -v grep | awk '{print $1}')
if [ "$ORPHAN_BUCK_PIDS" != "" ]
then
  echo "Killing orphan Buck builds: $ORPHAN_BUCK_PIDS"
  kill -9 $ORPHAN_BUCK_PIDS
fi

echo "Setting up BUCK Java args"
cat > .buckjavaargs <<EOF
  -XX:MaxPermSize=512m -Xms8000m -Xmx12000m
  EOF

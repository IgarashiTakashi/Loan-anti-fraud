set -e
# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
LANGUAGE=node
CC_SRC_PATH=/opt/gopath/src/github.com/loancc
# clean the keystore
rm -rf ./hfc-key-store
# launch network; create channel and join peer to channel
cd ../basic-network
./start.sh
# Now launch the CLI container in order to install, instantiate chaincode
docker-compose -f ./docker-compose.yml up -d cli
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n loancc -v 1.0 -p "$CC_SRC_PATH" -l node
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n loancc -l node -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
sleep 20
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n loancc -c '{"function":"initLedger","Args":[""]}'
printf "\n脚本启动时间 : $(($(date +%s) - starttime)) 秒 ...\n\n\n"
printf "执行'npm install' 安装依赖文件\n"
printf "执行 'node enrollAdmin.js', 创建管理员, 然后执行 'node registerUser'创建用户\n\n"
printf "执行 'node invoke.js' 调用函数\n"
printf "执行 'node query.js' 查询记录\n\n"

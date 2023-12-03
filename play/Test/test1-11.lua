--计算场内对方机器人开始标记
countRobotFlag = false
--全局变量,对方机器人场上编号集
robotNo = {} 
--全局变量, 保存守门员编号, 初始值16表示无守门员
goalieNo = 16
--全局变量,对方机器人场上数量
robotCount = 0

-- 取得
function getRobotNo()                
    if countRobotFlag  then
        for j = 0, param.maxPlayer-1 do
                if enemy.valid(j) then
                    robotCount = robotCount +1
                    robotNo[robotCount] = j
                    if enemy.posX(j) > param.pitchLength/2 -param.penaltyDepth and math.abs(enemy.posY(j)) < param.penaltyWidth/2 then 
                        goalieNo = j
                    end
                end
        end
    end 
    countRobotFlag = false
    return null
end 


gPlayTable.CreatePlay{

firstState = "test",

["test"] = {

        switch = function()
                countRobotFlag = true
                if bufcnt(true,1) then
                    return "test1"
                end 
        end,
        a = whtCommonTask.stop(),
        match = "{a}"
},



["test1"] = {

        switch = function()
                getRobotNo()
                debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,2500),"机器人数量:"..tostring(robotCount),2)
                debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,2000),"守门员编号:"..tostring(goalieNo),2)
                for j = 1, robotCount do
                    debugEngine:gui_debug_msg(CGeoPoint:new_local(1000,-500*j),"机器人编号:"..tostring(robotNo[j]),1)
                end  

        end,
        a = whtCommonTask.stop(),
        match = "{a}"
},


name = "test1-11",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}

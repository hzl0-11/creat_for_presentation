local DSS_FLAG = flag.allow_dss + flag.dodge_ball

local movePoint = function(role)
    return function()
        return ball.pos() +  Utils.Polar2Vector(300, (player.pos(role)-ball.pos()):dir())
    end
end

gPlayTable.CreatePlay{

firstState = "gradBall",

["gradBall"] = {
        switch = function()
                if bufcnt(player.infraredCount("a") > 1 ,3) then        
                    return "carryToMove"  
                end
        end,
        a = whtCommonTask.goCmuRush(ball.pos,dir.playerToBall,_,flag.allow_dss+flag.dribbling),
        match = "{a}"
},
--向前移动
["carryToMove"] = {
        switch = function()
                --移动过程中丢球，转移动过程中抢球
                if bufcnt(player.infraredCount("a") < 1,5) then
                    return "carry-grad"  --移动过程中丢球
                --到达目的地后,后退一段距离,重新带球
                elseif bufcnt(player.toTargetDist("a") < 10 ,3) then
                    whtAttackTask.specialMoveFlat = true
                    return "backMove" 
                end 
        end,
        a = whtAttackTask.carryToMove("a",1000),
        match = "{a}"
},

["carry-grad"] = {
        switch = function()              
                if bufcnt(player.infraredCount("a") > 1,3) then
                        return "carryToMove"
                end 
        end,
        a = whtCommonTask.goCmuRush(ball.pos,dir.playerToBall,_,flag.allow_dss+flag.dribbling),
        match = "{a}"
},

["backMove"] = {
        switch = function()
                if bufcnt(player.toTargetDist("a") < 10 ,3)  then        
                    return "gradBall"  
                end
        end,
        a = whtCommonTask.goCmuRush(movePoint("a"),dir.playerToBall,_,flag.nothing),
        match = "{a}"
},

name = "test1-09",
applicable ={
	exp = "a",
	a = true
},
attribute = "attack",
timeout = 99999
}

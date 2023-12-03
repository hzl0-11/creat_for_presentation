module(..., package.seeall)		
local DSS_FLAG = flag.allow_dss + flag.dodge_ball


-- 传球设计		
--					directPassBall(role,role1)	任意球发球时使用（不吸球）
--					dribblingPassBall(role,role1) : 吸球传球，平射或挑射自主选择


-- 2.6 传球设计		
function directPassBall(role,role1,speed)
	local pos1 = function()
		return ball.pos()			
	end
	local ikick = function()
			-- if whtFunction.canFlatPassToRole(role,role1) then
				return 1
			-- else
			-- 	return 2
			-- end
	end	
	-- local idir = function()
	-- 	return (player.pos(role1) - player.pos(role)):dir()
	-- end
	local idir = dir.playerToBall
	-- local ipos = pos1()     
    function specifiedFlat()
	   local pw 
	   if IS_SIMULATION then
	  		-- pw =  (ball.pos():dist(player.pos(role1)))*whtParam.simulationTimes + whtParam.simulationCompensate
			return 6000
	   else
			return 5000
	   end 
	end
	function specifiedChip()
		local pw 
		if IS_SIMULATION then
			return 3000
	    else
			return 3000
	    end 
	end
	local mexe, mpos = GoCmuRush{pos = pos1, dir = idir, acc = speed, flag = flag.allow_dss,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.high, specifiedFlat, specifiedChip, flag.allow_dss}
end 


function dribblingPassBall(role,role1,speed)
		local pos1 = function()
			local tempXY =  CGeoPoint:new_local(0,0) 
			return function()
			   	--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
				if whtCommonFunction.BallInField() then
					tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
				end 
				return tempXY	
			end
		end
		local ikick = function()
			-- if whtFunction.canFlatPassToRole(role,role1) then
				return 1
			-- else
			-- 	return 2
			-- end
		end			
		-- local idir = function()
		-- 	return (player.pos(role1) - player.pos(role)):dir()
		-- end
   		local idir = dir.playerToBall  
	    function specifiedFlat()
		   -- local pw 
		   -- local roleP = player.pos(role)
		   -- local roleP1 = player.pos(role1)
		   if IS_SIMULATION then

				return 6500
		   else
				return 650		   	
		   end 
			
		end
		function specifiedChip()
			-- local pw 
			-- local roleP = player.pos(role)
		    -- local roleP1 = player.pos(role1)
			if IS_SIMULATION then
				return 3000
		   else
				return 500
		   end 
		end
	local mexe, mpos = GoCmuRush{pos = pos1(), dir = idir, acc = speed, flag = flag.allow_dss+ flag.dribbling,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, flag.allow_dss+ flag.dribbling}
end 


function testPower(role,role1,kickflat,simulationPower,realPower,speed)
		local pos1 = function()
			local tempXY =  CGeoPoint:new_local(0,0) 
			return function()
			   	--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
				if whtCommonFunction.BallInField() then
					tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
				end 
				return tempXY	
			end
		end
		local ikick = kickflat

   		local idir = dir.playerToBall  
	    function specifiedFlat()
		   if IS_SIMULATION then
				return simulationPower
		   else
				return realPower		   	
		   end 
			
		end
		function specifiedChip()
			if IS_SIMULATION then
				return simulationPower
		   else
				return realPower
		   end 
		end
	local mexe, mpos = GoCmuRush{pos = pos1(), dir = idir, acc = speed, flag = flag.allow_dss+ flag.dribbling,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, flag.allow_dss+ flag.dribbling}
end 






















-- 射门		
-- 					directShoot() 	: 	直接射门  

function directShoot()
	local pos1 = function()
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
		   	--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtCommonFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			return tempXY
		end 			
	end
	-- local ikick = function()
	-- 	return 1
	-- end
	local ikick = kick.flat
	local idir = dir.playerToBall
    function specifiedFlat()
	   if IS_SIMULATION then
			return whtAttackParam.simulationMaxPower
	   else
			return whtAttackParam.realMaxPower
	   end 
	end
	function specifiedChip()
			return 0
	end
	-- 角度对准精度
    function customPre()
		return whtAttackParam.shootPre 
	end
	local mexe, mpos = GoCmuRush{pos = pos1(), dir = idir, acc = a, flag = flag.allow_dss,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, flag.allow_dss}
end 




--	    carryToMove(role,dist): 带球运行：运行到离role指定dist
								--   根据不同条件 ,分别为向二方球门中心
--定义一个全局变量，区分重复状态运行,初始值为true；
--此状态中本技能第一次进入时，得到运行的目的点，然后赋值为fasle，本技能每帧调用时，不会再更改目的点
--应用本技能的状态，在其到达目的地后需要转移到其他状态前，把全局变量的值赋值为true，下次再进此状态，会重新计算目的点
--如果带球移动过程中,球被抢, 进入其他状态前,也要把全局变量的值赋值为true，下次再进此状态，会重新计算目的点
specialMoveFlat = true
function carryToMove(role,dist)	
	local  ipos = function()
		local temp =  CGeoPoint:new_local(0,0)
		return function()
			if specialMoveFlat == true then
                -- 小于此位置,向对方球门中点移动
                if player.posX(role) < param.pitchLength/2 - 2500 then
                	temp  =  player.pos(role) +  Utils.Polar2Vector(dist, player.toTheirGoalDir(role))
                --大于此位置,向本方球门中点移动
                else
                	local tempDir = (CGeoPoint:new_local(-param.pitchLength/2,0) - player.pos(role)):dir()
                	temp  =  player.pos(role) +  Utils.Polar2Vector(dist, tempDir)
                end 
                -- 下一帧不会再计算移动点,在状态层面赋值为true,重新进入使用此技能的状态时会再次计算移动点
                specialMoveFlat = false
            end
			return  temp
		end 
	end
	--实地去测试角度随着对方机器人变化,能不能吸住球
	local idir =function()
		return player.dir(role)
	end
	local f = flag.allow_dss+flag.dribbling
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end



--	    carryToMove(role,dist): 带球转圈：半径为指定dist
-- speed 速度(度为单位)
specialMoveCircle = true
function carryToCircle(role,dist,speed)	
	local  ipos = function()
		local temp =  CGeoPoint:new_local(0,0)
		return function()
			if specialMoveCircle == true then
				--第一帧运行时,得到机器人的位置
                temp  =  CGeoPoint:new_local(player.posX(role),player.posY(role))
                -- 下一帧不会再计算移动点,在状态层面赋值为true,重新进入使用此技能的状态时会再次计算移动点
                specialMoveCircle = false
            end
			return  temp + Utils.Polar2Vector(dist,(player.pos(role) - temp):dir() + math.pi/180*speed)
		end 
	end
	--实地去测试角度随着对方机器人变化,能不能吸住球
	-- local idir =function()
	-- 	return player.dir(role)
	-- end
	local idir= dir.playerToBall
	local f = flag.allow_dss+flag.dribbling
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end









-- 		aroundBallToRobot(role,role1) : 围绕球旋转到传球方向
		

--		roundBallToShoot(role,dist) : 绕球旋转到射门方向
	--仿真下靠近球的最近距离:130以上(设为10)
	--精度设的低点,如0.2,因为早点停止,反而停止后精度很高.

function aroundBallToRobot(role,role1,dist)
	local ipos = function()		
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
	   		--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtCommonFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end	
			local playerDir =(tempXY-player.pos(role)):dir()
	    	local playerToGoal = player.toPlayerDir(role,role1)	
	        -- 通过二者弧度位置,得到顺时针还是逆时针
      		if  playerDir < playerToGoal - 0.2 then
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() + math.pi/180*whtAttackParam.roundBallSpeed)
	   		elseif playerDir > playerToGoal + 0.2 then
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() - math.pi/180*whtAttackParam.roundBallSpeed)
	   		else
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir())
	   		end     		
		end		
	end 
	-- local idir =function()
	-- 	return dir.playerToBall(role)
	-- end
	local idir = dir.playerToBall	
	local f = flag.allow_dss  + flag.dodge_ball
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


function roundBallToShoot(role,dist)
	local ipos = function()	
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
	   		--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtCommonFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
   			local playerDir =(tempXY - player.pos(role)):dir()
     		local playerToGoal = player.toTheirGoalDir(role)
      		-- if  playerDir < playerToGoal  then
	   		-- 	return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() + math.pi/180*whtAttackParam.roundBallSpeed)
	   		-- else
	   		-- 	return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() - math.pi/180*whtAttackParam.roundBallSpeed)
	   		-- end
      		if  playerDir < playerToGoal - 0.1 then
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() + math.pi/180*whtAttackParam.roundBallSpeed)
	   		elseif playerDir > playerToGoal + 0.1 then
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() - math.pi/180*whtAttackParam.roundBallSpeed)
	   		else
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir())
	   		end

		end  
	end 
	local idir = dir.playerToBall
	local f = flag.allow_dss  + flag.dodge_ball
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end



--				CSroundBallToShoot(role,dist) : 绕球旋转到射门方向(减速方式)
	--速度逐渐降低,精度可以设的高点,如0.01,初速也可以设的高点.

function CSroundBallToShoot(role,dist)
	local ipos = function()	
		local tempXY =  CGeoPoint:new_local(0,0) 
		local initArc = math.abs(player.toTheirGoalDir(role)-dir.playerToBall(role))
		return function()
			--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtCommonFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
	   		local playerDir =(tempXY - player.pos(role)):dir()
	        local playerToGoal = player.toTheirGoalDir(role)
			local nowArc = math.abs(playerToGoal-playerDir)
			local nowSpeed = nowArc/initArc*whtAttackParam.CSroundBallSpeed
      		if  playerDir < playerToGoal - 0.05 then
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir()  + math.pi/180*nowSpeed)
	   		elseif playerDir > playerToGoal + 0.05 then
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() - math.pi/180*nowSpeed)
	   		else
	   			return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir())
	   		end
		end 
	end 
	local idir = dir.playerToBall
	local f = flag.allow_dss +flag.dodge_ball
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


-- 2.2 	旋转	--注意无论何种方式都有加减速过程			
--				whirlRobotToShoot(role) : 机器人旋转到射门方向（吸球方式）
	-- 精度设得低点，以便更早的停下来，最终达到高精度
	-- 速度3, 精度设的低点,如0.2,因为早点停止,反而停止后精度很高
--				CSwhirlRobotToShoot(role) : 机器人旋转到射门方向（吸球方式)(减速方式)
	--精度可以直接设的很高
	--速度3,控制速度减少下,精度可以高的很高,如0.01

-- 2.2 	旋转
function whirlRobotToShoot(role)
	local spdW = function()
		local playerDir =player.dir(role)
        local playerToGoal = player.toTheirGoalDir(role)
        -- 二者弧度相差一定范围内,表示到达目标
        if math.abs(playerToGoal-playerDir) > whtAttackParam.whirlArcToShoot then
            -- 通过二者弧度位置,得到顺时针还是逆时针
            if  playerDir < playerToGoal then
           		if IS_SIMULATION then
					return whtAttackParam.whirlSimulationSpeed
		   		else
					return whtAttackParam.whirlSpeed
		   		end 
           	else
           		if IS_SIMULATION then
					return whtAttackParam.whirlSimulationSpeed1
		   		else
					return whtAttackParam.whirlSpeed1
		   		end 
           	end          
        else
            return 0 
        end	
	end
	local idir =function()
		return player.dir(role)
	end
	local ikick = function()
		return 0
	end
    function specifiedFlat()
	   return 0 
	end
    function specifiedChip()
		return 0
	end
	local mexe, mpos = Speed{speedW = spdW}
	return {mexe, mpos, ikick, idir,pre.high, specifiedFlat, specifiedChip,flag.allow_dss+flag.dribbling}
end


function CSwhirlRobotToShoot(role)
	local spdW = function()
		local initArc = math.abs(player.toTheirGoalDir(role)-player.dir(role))
        return function()
			local playerDir =player.dir(role)
	        local playerToGoal = player.toTheirGoalDir(role)
			local nowArc = math.abs(playerToGoal-playerDir)
			local nowSpeed = nowArc/initArc*whtAttackParam.initSpeed
            if nowArc > whtAttackParam.CSwhirlArcToShoot then
	            if  playerDir < playerToGoal then
						return nowSpeed
	           	else
						return -nowSpeed
	           	end  
	        else
	        	return 0
	        end     
	    end 
	end
	local idir =function()
		return player.dir(role)
	end
	local ikick = function()
		return 0
	end
    function specifiedFlat()
	   return 0 
	end
    function specifiedChip()
		return 0
	end
	local mexe, mpos = Speed{speedW = spdW()}
	return {mexe, mpos, ikick, idir,pre.high, specifiedFlat, specifiedChip,flag.allow_dss+flag.dribbling}
end











	-- 	local ballPos = ball.pos()
	-- 	local goalPos1  -- 球门的二边点坐标
	-- 	local goalPos2
	-- 	-- 根据球的位置,确定先判断射哪边
	-- 	if ball.posY() > 0 then
	-- 		goalPos1 = CGeoPoint:new_local(param.pitchLength/2,param.goalWidth/2-shootPos2EdgeDist)
	-- 		goalPos2 = CGeoPoint:new_local(param.pitchLength/2,-param.goalWidth/2+shootPos2EdgeDist)
	-- 	else
	-- 		goalPos1 = CGeoPoint:new_local(param.pitchLength/2,-param.goalWidth/2+shootPos2EdgeDist)
	-- 		goalPos2 = CGeoPoint:new_local(param.pitchLength/2,param.goalWidth/2-shootPos2EdgeDist)
	-- 	end 
	-- 	--射门线段
	-- 	local seg1 = CGeoSegment:new_local(ballPos, goalPos1)
	-- 	-- 是否阻挡标志 true为没有阻挡
	-- 	local flag = true

	-- 	local enemyPoint  -- 对方机器人位置
	-- 	local prejectPos  -- 投影点
	-- 	local enemy2prejectPosDist -- 投影点和对方机器人的距离
	-- 	local isprjon --是否在线段内的标志

	-- 	for i = 0, param.maxPlayer-1 do		
	-- 		if enemy.valid(i) then
	-- 			enemyPoint = enemy.pos(i)
	-- 			prejectPos = seg1:projection(enemyPoint)
	-- 			isprjon = seg1:IsPointOnLineOnSegment(prejectPos)
	-- 			if 	isprjon then
	-- 				enemy2prejectPosDist = prejectPos:dist(enemyPoint)
	-- 				if enemy2prejectPosDist <  enemy2ShootLineDist then
	-- 					flag = false
	-- 					break
	-- 				end					
	-- 			end 			
	-- 		end
	-- 	end
	-- 	local idir
	-- 	local iPos
	-- 	if flag then
	-- 		idir = (ball.pos() - goalPos1):dir()
    --   		iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
    --   		return iPos 
	-- 	end
	-- 	flag = true  
	-- 	local seg2 = CGeoSegment:new_local(ballPos, goalPos2)

	-- 	for i = 0, param.maxPlayer-1 do		
	-- 		if enemy.valid(i) then
	-- 			enemyPoint = enemy.pos(i)
	-- 			prejectPos = seg2:projection(enemyPoint)
	-- 			isprjon = seg1:IsPointOnLineOnSegment(prejectPos)
	-- 			if 	isprjon then
	-- 				enemy2prejectPosDist = prejectPos:dist(enemyPoint)
	-- 				if enemy2prejectPosDist <  enemy2ShootLineDist then
	-- 					flag = false
	-- 					break
	-- 				end					
	-- 			end 			
	-- 		end
	-- 	end

	-- 	if flag then
	-- 		idir = (ball.pos() - goalPos2):dir()
    --   		iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
    --   		return iPos 
	-- 	else
    --  	    idir = (ball.pos() - pos.theirGoal()):dir()
	-- 	    iPos = ball.pos() + Utils.Polar2Vector(dist,idir)
	-- 	    return iPos			
	-- 	end

































-- 进攻及辅助技能：
-- 2.1 抢球设计		
-- 					grabBal(role)

-- 2.2 	旋转	--注意无论何种方式都有加减速过程			
--				whirlRobotToShoot(role) : 机器人旋转到射门方向（吸球方式）
	-- 精度设得低点，以便更早的停下来，最终达到高精度
	-- 速度3, 精度设的低点,如0.2,因为早点停止,反而停止后精度很高
--				CSwhirlRobotToShoot(role) : 机器人旋转到射门方向（吸球方式)(减速方式)
	--精度可以直接设的很高
	--速度3,控制速度减少下,精度可以高的很高,如0.01
--				whirlRobotToPassBall(role,role1) : 旋转到传球方向(吸球方式)
-- 				whirlRobotToCarry(role) : 吸着球转身（可用来与对方争抢球）



-- 				aroundBallToRobot(role,role1) : 围绕球旋转到传球方向
--				roundBallToShoot(role,dist) : 绕球旋转到射门方向
	--仿真下靠近球的最近距离:130以上(设为10)
	--精度设的低点,如0.2,因为早点停止,反而停止后精度很高.
--				CSroundBallToShoot(role,dist) : 绕球旋转到射门方向(减速方式)
	--速度逐渐降低,精度可以设的高点,如0.01,初速也可以设的高点.




--6.3 					whirlRobotAroundBallToRobot(role,role1) : 围绕球旋转到传球方向
--6.4 					whirlRobotAroundBallToEnemy(role) : 围绕球旋转到最近敌方的方向
--6.5 					whirlRobotToAdvance(role) :旋转到前进方向(吸球方式)




-- 2.4 接球机器人跑位
--			receiveP(role,dist,arc,dist1)： 接球点
--					dist:接球点长度3000，arc:接球阻挡一边的弧度0.1，dist1:球门中心离射门点的距离，同下
--					role :  发球机器人
--			shootPoint(position,dist,arc): 禁区外的三个射门位置
--					position: left ,right , or  center
-- 					left,right使用dist：2100，center: 1700,arc为传球限制弧度: 0.1(一边为5度)
--	    carryToMove(role,dist): 带球运行：运行到离role指定dist
								--   根据不同条件 ,分别为向二方球门中心
--			disturbP(role,dist)： 干绕点(假接球点)
--							role: 发球机器人



-- 	preparePoint2Corner(n): 当属于corner进攻时,放球时的进攻准备位置
-- 	preparePoint2Other(n): 当属于other进攻时,放球时的进攻准备位置

-- 2.5 截球设计		
-- 					interBall()：直接截球，前置几帧使用停止状态或使用下面的预截球
--					beginInterBall(role)：预截球，移动到机器人指向球的方向 role指的是持球机器人



-- 2.6 传球设计		
--					cornerPassBall(role,role1)	任意球发球时使用（不吸球）



-- 进攻及辅助技能：




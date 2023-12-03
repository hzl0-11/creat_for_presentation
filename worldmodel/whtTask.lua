module(..., package.seeall)		
local DSS_FLAG = flag.allow_dss + flag.dodge_ball
-- 自定义技能函数:
-- 重要提示
-- 判断对方机器人是否存在,可用enemy.valid(num),
-- 但判断本方机器人是否存在,应用 player.num(role) ~= -1  或player.valid(num) 来判断(num必须直接设置数字)

-- runner : 代表角色本身,如不能使用,说明在上一层的技能函数中没有引用,可以修改上一层技能函数
-- 使用了runner后,在单个函数测试时出问题(找不到对应的机器人),在多个状态中运行正常(不在第一个状态),
-- 这个问题是可以解决的,使用runner必须在之前有匹配,可在单个函数测试时前置一个状态
-- 注: 使用runner 的state不能放在第一个
-- 使用runner后,测试时球出界,会出现找不到机器人的提示错误, 或者脚本还在运行,直接拉球入场内,也会提示错误
-- 为了使球在界外时,调试程序不出问题,技能函数使用runner的地方还是改为传入角色值为好

-- 经再次测试：  使用runner的角色必须在config文件中固定角色匹配，能放在第一个状态

-- idir = dir.playerToBall 这个函数调用,应该需要代表机器人的参数dir.playerToBall(role),为什么有些地方不需要
-- 原因是在上一层的技能函数接口中需要使用idir弧度,在内部调用了runner表示本身这个角色
-- 如上一层技能函数:GoCmuRush,RunMultiPos
-- 在lua层面的接口中,使用idir弧度,计算与角色相关的弧度时,必须传入角色值
-- dir.shoot(),同理可以不是dir.shoot()(role)

					



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



-- 2.3 射门及传球设计				
-- 					shoot(role，chip) 	: 	射门(chip为true:挑射)
--					kickBall(role,role1) : 吸球传球，平射或挑射自主选择
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



-- 2.6 传球设计		
function cornerPassBall(role,role1)
	local pos1 = function()
		return ball.pos()			
	end
	local ikick = function()
			if whtFunction.canFlatPassToRole(role,role1) then
				return 1
			else
				return 2
			end
	end	
	local idir = function()
		return (player.pos(role1) - player.pos(role)):dir()
	end

	-- local ipos = pos1()     
    function specifiedFlat()
	   local pw 
	   -- if IS_SIMULATION then
	  -- 		pw =  (ball.pos():dist(player.pos(role1)))*whtParam.simulationTimes + whtParam.simulationCompensate
	  -- 		if pw < whtParam.simulationMinPower then   
		-- 		pw = whtParam.simulationMinPower 					
		-- 	elseif pw > whtParam.simulationMaxPower then
		-- 		pw = whtParam.simulationMaxPower
		-- 	end
		-- 	return pw
	   -- else
	  -- 		pw =  (ball.pos():dist(player.pos(role1)))*whtParam.realTimes + whtParam.realCompensate
		-- 	if pw < whtParam.realMinPower then    
		-- 		pw = whtParam.realMinPower 			
		-- 	elseif pw > whtParam.realMaxPower then
		-- 		pw = whtParam.realMaxPower
		-- 	end
		-- 	return pw
			return 6000
	   -- end 
	end
	function specifiedChip()
		local pw 
		if IS_SIMULATION then
	  		pw =  (ball.pos():dist(player.pos(role1))) * whtParam.simulationChipTimes
			if pw < whtParam.simulationChipMinPower then    
				pw = whtParam.simulationChipMinPower			
			elseif pw > whtParam.simulationChipMaxPower then
				pw = whtParam.simulationChipMaxPower
			end
			return pw
	   else
	  		pw =  (ball.pos():dist(player.pos(role1))) * whtParam.realChipTimes
			if pw < whtParam.realChipMinPower then    
				pw = whtParam.realChipMinPower			
			elseif pw > whtParam.realChipMaxPower then
				pw = whtParam.realChipMaxPower		
			end
			return pw
			-- return 2000
	   end 
	end
	local mexe, mpos = GoCmuRush{pos = pos1, dir = idir, acc = 500, flag = flag.allow_dss,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.high, specifiedFlat, specifiedChip, flag.allow_dss}
end 




-- 2.5 截球设计	
-- 速度大于moveSpeed1时:运动到来球方向的垂直点上接球
-- 速度大于moveSpeed2时:向来球方向运动,保持离球某个距离(distToBall)
-- 速度小于moveSpeed2时:直接向球运动拿球

function interBall()
	local ipos =function()
		--如果球在场内,由于视觉原因消失不见(或不在场内),如何得到前一个可见位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		local tempDir = -math.pi -- 保存当前帧的球的弧度
		local tempMod = 0
		return function(runner)
			local temp --返回点
			--如果球没有消失且在场内, 保存当前球的位置和弧度,速度，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
				tempDir = ball.velDir()
				tempMod = ball.velMod()
			end		
			-- 速度大于moveSpeed1时, 返回投影点
			if tempMod >whtParam.moveSpeed1 then
				local playerP = player.pos(runner)
				local movePoint = tempXY + Utils.Polar2Vector(1000,tempDir)
				local seg = CGeoSegment:new_local(tempXY, movePoint)
				temp = seg:projection(playerP)
				return  temp
			-- 速度大于moveSpeed2时, 向球移动,离球一定距离
			elseif tempMod >whtParam.moveSpeed2 then
				temp = tempXY + Utils.Polar2Vector(whtParam.distToBall,tempDir)
				return  temp
			-- 速度小于moveSpeed2时, 向球移动,吸球
			else
				return tempXY
			end
		end  
	end	
	local idir = dir.playerToBall
	local f = flag.allow_dss+flag.dribbling
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end

function beginInterBall(role)
	local ipos =function()
		--如果球在场内,由于视觉原因消失不见(或不在场内),如何得到前一个可见位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function(runner)
			local temp --返回点
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end			
			local playerP = player.pos(role)
			local runnerP = player.pos(runner)
			local movePoint = playerP + Utils.Polar2Vector(1000,(tempXY-playerP):dir())
			local seg = CGeoSegment:new_local(tempXY, movePoint)
			temp = seg:projection(runnerP)
			return  temp
		end  
	end	
	local idir = dir.playerToBall
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end




-- 2.4 接球机器人跑位

function preparePoint2Corner(n)
	local ipos =function()	
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			local staticPos = CGeoPoint:new_local(param.pitchLength/2,0)
			local tempY = tempXY:y()  --球的y坐标
			local tempP = CGeoPoint:new_local(0,0)   -- 返回位置
			if n ==1 then
				if tempY > 0 then
					tempP = tempXY +  Utils.Polar2Vector(4000, -5*math.pi/6)
				else
					tempP = tempXY +  Utils.Polar2Vector(4000, 5*math.pi/6)
				end 
			elseif n==2 then
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 600,500)				
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 600,-500)
				end 
			elseif n ==3  then
				if tempY > 0 then				
					-- for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, -1.93)
						-- if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
						-- 	return tempP
						-- end 
					-- end
					-- tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-param.penaltyWidth/2 - 500)	
				else
					-- for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, 1.93)
						-- if whtFunction.canBallPassToPos(tempP) and  whtFunction.canFlatShoot(tempP) then
						-- 	return tempP
						-- end 
					-- end
					-- tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,param.penaltyWidth/2 + 500)
				end 
			elseif n ==4  then
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2 - 200,param.penaltyWidth/2 + 300)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2- 200,-param.penaltyWidth/2 - 300)
				end 
			
			elseif n ==5  then
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,-500)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,500)
				end		
			
			elseif n ==6  then   --- 角球第二种打法时,kicker角色的走位
				if tempY > 0 then				
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2500, -3*math.pi/4+i*0.08)
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-param.penaltyWidth/2 - 500)	
				else
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2500, 3*math.pi/4-i*0.08)
						if whtFunction.canBallPassToPos(tempP) and  whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,param.penaltyWidth/2 + 500)
				end 
			elseif n ==7  then   --- 角球第二种打法时,a角色的走位
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,param.pitchWidth/2+500)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-param.pitchWidth/2-500)
				end 
			elseif n ==8  then   --- 角球第二种打法时,b角色的走位
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2-800 ,param.pitchWidth/2+300)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2-800 ,-param.pitchWidth/2-300)
				end 
			end 			
			return tempP
		end  
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end

function preparePoint2Front(n)
	local ipos =function()	
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			local staticPos = CGeoPoint:new_local(param.pitchLength/2,0)
			local tempY = tempXY:y()  --球的y坐标
			local tempX = tempXY:x()  --球的x坐标
			local tempP = CGeoPoint:new_local(0,0)   -- 返回位置
			if n ==1 then
				if tempY > 0 then
					if tempX < 2000 then
						tempP = tempXY +  Utils.Polar2Vector(3500, -math.pi/2)
					else
						tempP = tempXY +  Utils.Polar2Vector(3500, -2*math.pi/3)
					end 
				else
					if tempX < 2000 then
						tempP = tempXY +  Utils.Polar2Vector(3500, math.pi/2)
					else
						tempP = tempXY +  Utils.Polar2Vector(3500, 2*math.pi/3)
					end 
				end 
			elseif n==2 then
				if tempY > 0 then
					for i = 0 ,2 do
						tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth + 300 - i*300,-param.penaltyWidth/2 - 800 + i*300) 
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-param.penaltyWidth/2 - 500)					
				else
					for i = 0 ,2 do
						tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth + 300 - i*300,param.penaltyWidth/2 + 800 - i*300) 
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,param.penaltyWidth/2 + 500)					
				end 
			elseif n ==3  then
				if tempY > 0 then				
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, 1.9 + i*0.2)
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2- 800,param.penaltyWidth/2 + 300)	
				else
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, -1.9 - i*0.2)
						if whtFunction.canBallPassToPos(tempP) and  whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2- 1000,-param.penaltyWidth/2 - 300)	
				end 
			elseif n ==4  then
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2 -param.penaltyDepth- 300,param.penaltyWidth/2 + 300)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2 -param.penaltyDepth- 300,-param.penaltyWidth/2 - 300)
				end 
			
			elseif n ==5  then
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,-500)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,500)
				end		
			
			elseif n ==6  then   --- 角球第二种打法时,kicker角色的走位
				if tempY > 0 then				
					tempP = CGeoPoint:new_local(param.pitchLength/2-600,-param.penaltyWidth/2 - 300)	
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2- 600,param.penaltyWidth/2 + 300)
				end 
			elseif n ==7  then   --- 角球第二种打法时,a角色的走位
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,500)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-500)
				end	 
			end 			
			return tempP
		end  
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end



function preparePoint2Back(n)
	local ipos =function()	
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			local staticPos = CGeoPoint:new_local(param.pitchLength/2,0)
			local tempY = tempXY:y()  --球的y坐标
			local tempX = tempXY:x()  --球的x坐标
			local tempP = CGeoPoint:new_local(0,0)   -- 返回位置
			if n ==1 then
				if tempY > 0 then
		        	for i = 0 ,2 do
						tempP = tempXY +  Utils.Polar2Vector(4000,  -math.pi/4 - i*0.26)
						if whtFunction.canPassToPos(tempXY,tempP,0.1)  then
							return tempP
						end 
					end
					tempP = tempXY +  Utils.Polar2Vector(4500,-math.pi/4)	
				else		        	
		        	for i = 0 ,2 do
						tempP = tempXY +  Utils.Polar2Vector(4000,  math.pi/4  + i*0.26)
						if whtFunction.canPassToPos(tempXY,tempP,0.1)  then
							return tempP
						end 
					end
					tempP = tempXY +  Utils.Polar2Vector(4000,math.pi/4)	
				end 
			elseif n==2 then
				if tempY > 0 then		        	
		        	for i = 0 ,2 do
						tempP = tempXY +  Utils.Polar2Vector(4000,  -i*0.13)
						if whtFunction.canPassToPos(tempXY,tempP,0.1)  then
							return tempP
						end 
					end
					tempP = tempXY +  Utils.Polar2Vector(4000,-0.1)	
				else		        	
		        	for i = 0 ,2 do
						tempP = tempXY +  Utils.Polar2Vector(4000,  i*0.13)
						if whtFunction.canPassToPos(tempXY,tempP,0.1)  then
							return tempP
						end 
					end
					tempP = tempXY +  Utils.Polar2Vector(4000,0.1)	
				end
			elseif n ==3  then
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 1500,200)
			elseif n ==4  then		
				if tempY > 0 then
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, 1.9 + i*0.2)
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2- 800,param.penaltyWidth/2 + 300)				
				else
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, -1.9 - i*0.2)
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2- 800,-param.penaltyWidth/2 - 300)				
				end 
			elseif n ==5  then
				if tempY > 0 then
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, -1.9 - i*0.2)
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2- 800,-param.penaltyWidth/2 - 300)				
				else
					for i = 0 ,2 do
						-- 1.83 意味着从105度开始，每次0.26(约15度)
						tempP = staticPos +  Utils.Polar2Vector(2100, 1.9 + i*0.2)
						if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
							return tempP
						end 
					end
					tempP = CGeoPoint:new_local(param.pitchLength/2- 800,param.penaltyWidth/2 + 300)				
				end
			elseif n ==6  then   
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 400, 600)
			elseif n ==7  then  
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 600, -400) 	
			elseif n ==8  then  
				tempP = CGeoPoint:new_local(param.pitchLength/4 , -800) 	 
			elseif n ==9  then  
				tempP = CGeoPoint:new_local(param.pitchLength/4 , 600) 		 
			end 			
			return tempP
		end  
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end



function preparePoint2KickOff(n)
	local ipos =function()	
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			local staticPos = CGeoPoint:new_local(param.pitchLength/2,0)
			local tempY = tempXY:y()  --球的y坐标
			local tempX = tempXY:x()  --球的x坐标
			local tempP = CGeoPoint:new_local(0,0)   -- 返回位置
			if n ==1 then	        	
				tempP = CGeoPoint:new_local(1500,1000)	
			elseif n==2 then
				tempP = CGeoPoint:new_local(1500,-1000)	
			elseif n ==3  then
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 1500,200)
			elseif n ==4  then		
				for i = 0 ,2 do
					tempP = staticPos +  Utils.Polar2Vector(2300, -3*math.pi/4 -0.2+ i*0.2)
					if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
						return tempP
					end 
				end
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth- 500,-param.penaltyWidth/2 - 500)				
			elseif n ==5  then
				for i = 0 ,2 do
					tempP = staticPos +  Utils.Polar2Vector(2300, 3*math.pi/4 +0.2-i*0.2)
					if whtFunction.canBallPassToPos(tempP) and whtFunction.canFlatShoot(tempP) then
						return tempP
					end 
				end
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth- 500,param.penaltyWidth/2 + 500)
			elseif n ==6  then   
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 400, 600)
			elseif n ==7  then  
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500, -400) 	
			elseif n ==8  then  
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth- 800,-param.penaltyWidth/2 - 700)				 	 
			elseif n ==9  then  
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth- 800,param.penaltyWidth/2 + 700)	 
			end 			
			return tempP
		end  
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end



function preparePoint2Other(n)
	local ipos =function()	
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			
			local tempY = tempXY:y()  --球的y坐标
			local tempP = CGeoPoint:new_local(0,0)   -- 返回位置
			if n ==1 then
				if tempY > 0 then
					tempP = tempXY +  Utils.Polar2Vector(3000, -math.pi/2)
				else
					tempP = tempXY +  Utils.Polar2Vector(3000, math.pi/2)
				end 
			elseif n==2 then
				if tempY > 0 then
					tempP = tempXY +  Utils.Polar2Vector(3500, -math.pi/4)
				else
					tempP = tempXY +  Utils.Polar2Vector(3500, math.pi/4)
				end 
			else
				if tempY > 0 then
					tempP = CGeoPoint:new_local(param.pitchLength/2 - 500,param.penaltyWidth/2 + 300)
				else
					tempP = CGeoPoint:new_local(param.pitchLength/2- 500,-param.penaltyWidth/2 - 300)
				end 
			end 			
			return tempP
		end  
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end




function receiveP(role,dist,arc,dist1)
	local ipos =function()
		local playerP = player.pos(role)
		local playerX = playerP:x()
		local playerY = playerP:y()		
		local temp = playerP +  Utils.Polar2Vector(dist,0) --每个点位的默认位置 		
        --持球机器人的位置1
        if playerY > 2500 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,0)
        	for i = 0 ,3 do
				temp = playerP +  Utils.Polar2Vector(dist,  -math.pi/4 + i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end 
			end		
		--持球机器人的位置2
		elseif playerY < -2500 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,0)
        	for i = 0 ,3 do
				temp = playerP +  Utils.Polar2Vector(dist,  math.pi/4 - i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end 
			end		        
        --持球机器人的位置3
        elseif  playerY < 2500 and playerY > 0 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,0)
        	for i = 0 ,6 do
				temp = playerP +  Utils.Polar2Vector(dist,  -math.pi/4 + i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end 
			end
        --持球机器人的位置4
        elseif  playerY > -2500 and playerY < 0 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,0)
        	for i = 0 ,6 do
				temp = playerP +  Utils.Polar2Vector(dist,  math.pi/4 - i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end      
			end 
        
      --持球机器人的位置5 -9 -8
        elseif playerY > 2500 and playerX > 4000 then
        	temp = playerP +  Utils.Polar2Vector(dist-1000,-3*math.pi/4)
        	for i = 0 ,3 do
				temp = playerP +  Utils.Polar2Vector(dist-1000,  -3*math.pi/4 - i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end 
			end		
		--持球机器人的位置6-10-7
		elseif playerY < -2500 and playerX > 4000 then
        	temp = playerP +  Utils.Polar2Vector(dist-1000,3*math.pi/4)
        	for i = 0 ,3 do
				temp = playerP +  Utils.Polar2Vector(dist-1000,  3*math.pi/4 + i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end 
			end		        
        --持球机器人的位置7-9-8
        elseif  playerY < 2500 and playerY > 0 and playerX > 4000 then
        	temp = playerP +  Utils.Polar2Vector(dist-1000,-math.pi)
        	for i = 0 ,6 do
				temp = playerP +  Utils.Polar2Vector(dist-1000,  -5*math.pi/6 - i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end 
			end
        --持球机器人的位置8-10-7
        elseif  playerY > -2500 and playerY < 0 and playerX > 4000  then
        	temp = playerP +  Utils.Polar2Vector(dist-1000,-math.pi)
        	for i = 0 ,6 do
				temp = playerP +  Utils.Polar2Vector(dist-1000,  5*math.pi/6 + i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc)  then
					return temp
				end
			end 

        --持球机器人的位置9-8
        elseif   playerY > 0 and playerX > 2000 and playerX < 4000 then
			temp = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,-param.penaltyWidth/2 -300)
			for i = 0 ,3 do
				temp = CGeoPoint:new_local(param.pitchLength/2,0) +  Utils.Polar2Vector(dist1, -1.83-i*0.26)
				if whtFunction.canPassToPos(playerP,temp,arc) and whtFunction.canFlatShoot(temp) then
					return temp
				end 
			end	
        --持球机器人的位置10-7
        elseif  playerY < 0 and playerX > 2000 and playerX < 4000  then
				temp = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,param.penaltyWidth/2 + 300)
				for i = 0 ,3 do
					temp = CGeoPoint:new_local(param.pitchLength/2,0) +  Utils.Polar2Vector(dist1, 1.83+i*0.26)
					if whtFunction.canPassToPos(playerP,temp,arc) and whtFunction.canFlatShoot(temp) then
						return temp
					end 
				end	      
        end      
		return  temp
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


function shootPoint(position,dist,arc)
	local ipos =function()	
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			local tempP 
			local staticPos = CGeoPoint:new_local(param.pitchLength/2,0)
			-- 1.83 意味着从105度开始，每次0.26(约15度)
			if position =="left"	then
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,param.penaltyWidth/2 + 300)
				for i = 0 ,3 do
					tempP = staticPos +  Utils.Polar2Vector(dist, 1.83+i*0.26)
					if whtFunction.canPassToPos(tempXY,tempP,arc) and whtFunction.canFlatShoot(tempP) then
						break
					end 
				end	
			elseif position =="right" then
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 300,-param.penaltyWidth/2 - 300)
				for i = 0 ,3 do
					tempP = staticPos +  Utils.Polar2Vector(dist, -1.83-i*0.26)
					if whtFunction.canPassToPos(tempXY,tempP,arc) and whtFunction.canFlatShoot(tempP) then
						break
					end 
				end	
			else
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-100)
				if tempXY:y() >  0 then
					for i = 0 ,2 do
						tempP = staticPos +  Utils.Polar2Vector(dist, -math.pi + i*0.26)
						if whtFunction.canPassToPos(tempXY,tempP,arc) and whtFunction.canFlatShoot(tempP) then
							break
						end 
					end	
				else
					for i = 0 ,2 do
						tempP = staticPos +  Utils.Polar2Vector(dist, math.pi-i*0.26)
						if whtFunction.canPassToPos(tempXY,tempP,arc) and whtFunction.canFlatShoot(tempP) then
							break
						end 
					end
				end 
			end 
			return tempP
		end  
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


--定义一个全局变量，区分重复状态运行,初始值为true；
--此状态中本技能第一次进入时，得到运行的目的点，然后赋值为fasle，本技能每帧调用时，不会再更改目的点
--应用本技能的状态，在其满足条件需要转移到其他状态前，把全局变量的值赋值为true，下次再进此状态，会重新计算目的点
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


function disturbP1(role,dist)
	local ipos =function()
		local playerP = player.pos(role)
		local playerX = playerP:x()
		local playerY = playerP:y()		
		local temp = playerP +  Utils.Polar2Vector(dist,0) --每个点位的默认位置 		
        --持球机器人的位置1
        if playerY > 2500 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,-math.pi/6)
			return temp
		--持球机器人的位置2
		elseif playerY < -2500 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,math.pi/6)
			return temp       
        --持球机器人的位置3
        elseif  playerY < 2500 and playerY > 0 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,-math.pi/6)
			return temp
        --持球机器人的位置4
        elseif  playerY > -2500 and playerY < 0 and playerX < 2000 then
        	temp = playerP +  Utils.Polar2Vector(dist,math.pi/6)
			return temp
      --持球机器人的位置5 -(7)
        elseif playerY > 2500 and playerX > 4000 then
        	temp = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,param.penaltyWidth/2 + 500)
			return temp
		--持球机器人的位置6-(8)
		elseif playerY < -2500 and playerX > 4000 then
        	temp = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-param.penaltyWidth/2 - 500)
			return temp      
        --持球机器人的位置7-(9)
        elseif  playerY < 2500 and playerY > 0 and playerX > 4000 then
        	temp = playerP +  Utils.Polar2Vector(dist-2000,5*math.pi/6)
			return temp
        --持球机器人的位置8-(10)
        elseif  playerY > -2500 and playerY < 0 and playerX > 4000  then
        	temp = playerP +  Utils.Polar2Vector(dist-2000,-5*math.pi/6)
			return temp
        --持球机器人的位置9-(7)
        elseif   playerY > 0 and playerX > 2000 and playerX < 4000 then
			temp = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,param.penaltyWidth/2 + 500)
			return temp
        --持球机器人的位置10-(8)
        elseif  playerY < 0 and playerX > 2000 and playerX < 4000  then
			temp = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-param.penaltyWidth/2 - 500)
			return temp     
        end      
		return  temp
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end

function disturbP2()
	local ipos =function()	
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			if tempXY:x() >  2000 then
				tempP = CGeoPoint:new_local(11*param.pitchLength/24+100,-param.penaltyWidth/2-300)
			else
				tempP = CGeoPoint:new_local(param.pitchLength/2-param.penaltyDepth - 500,-100)
			end  
			return tempP
		end  
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end




-- 2.1. 抢球设计
-- 球速高于设定值时,直接向球的前面位置跑
-- 如果角色直接能运行到球坐标,直接向球坐标移动
-- 如果球离对方机器人200毫米内,绕到对方机器人的前面,到离球300毫米处
-- 如果对方机器人只是挡住了直线移动,还是直接向球坐标移动(通过避障功能自动避开对方机器人)
function grabBall(role)
	local ipos =function()
		--保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		local tempXY =  CGeoPoint:new_local(0,0) 
		local tempDir = -math.pi -- 保存当前帧的球的弧度
		return function()
			--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
				tempDir = ball.velDir()
			end 			
			-- 球正在移动,向球的移动方向前面跑
			if	ball.velMod() > whtParam.grabBallSpeed then
				return  tempXY + Utils.Polar2Vector(whtParam.grabToBallDist,tempDir)
			-- 否则,根据有无阻挡选择不同的方式
			else
				local playerP = player.pos(role)
				local seg = CGeoSegment:new_local(playerP, tempXY)
				for i = 0, param.maxPlayer - 1 do
					if enemy.valid(i) then
						local enemyPoint = enemy.pos(i)
						local projectionP = seg:projection(enemyPoint)
						local dist = projectionP:dist(enemyPoint)
						local isprjon = seg:IsPointOnLineOnSegment(projectionP)
						-- 有对方机器人阻挡抢球线,绕到对方机器人的前面
						-- 条件：对方有机器人在连线内，与球的距离小于设定值，且与连线的垂直距离小于设定值
						if dist < whtParam.grabBlockDist and isprjon and enemyPoint:dist(tempXY) < whtParam.grabBalltoRole then
							return tempXY + Utils.Polar2Vector(whtParam.grabRoundDist,(tempXY-enemyPoint):dir())
						end
					end
				end
				return  tempXY
			end 
		end
	end
	local idir = dir.playerToBall
	local f = flag.dribbling + flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos(role), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end

-- 2.2 	旋转
function whirlRobotToShoot(role)
	local spdW = function()
		local playerDir =player.dir(role)
        local playerToGoal = player.toTheirGoalDir(role)
        -- 二者弧度相差一定范围内,表示到达目标
        if math.abs(playerToGoal-playerDir) > whtParam.whirlArcToShoot then
            -- 通过二者弧度位置,得到顺时针还是逆时针
            if  playerDir < playerToGoal then
           		if IS_SIMULATION then
					return whtParam.whirlSimulationSpeed
		   		else
					return whtParam.whirlSpeed
		   		end 
           	else
           		if IS_SIMULATION then
					return whtParam.whirlSimulationSpeed1
		   		else
					return whtParam.whirlSpeed1
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
			local nowSpeed = nowArc/initArc*whtParam.initSpeed
            if nowArc > whtParam.CSwhirlArcToShoot then
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

function whirlRobotToPassBall(role,role1)
	local spdW = function()
		local playerDir =player.dir(role)
        local playerToGoal = (player.pos(role1)-player.pos(role)):dir()
        -- 二者弧度相差一定范围内,表示到达目标
        if math.abs(playerToGoal-playerDir) > whtParam.whirlArcToPassBall  then
            -- 通过二者弧度位置,得到顺时针还是逆时针
            if playerToGoal < 0 then
	            if  playerDir > playerToGoal and playerDir < math.pi + playerToGoal then
	           		if IS_SIMULATION then
						return whtParam.whirlSimulationSpeed1
			   		else
						return whtParam.whirlSpeed1
			   		end 
	           	else
	           		if IS_SIMULATION then
						return whtParam.whirlSimulationSpeed
			   		else
						return whtParam.whirlSpeed
			   		end 
	           	end
	        else
	            if  playerDir < playerToGoal and playerDir > playerToGoal - math.pi   then
	           		if IS_SIMULATION then
						return whtParam.whirlSimulationSpeed
			   		else
						return whtParam.whirlSpeed
			   		end 
	           	else
	           		if IS_SIMULATION then
						return whtParam.whirlSimulationSpeed1
			   		else
						return whtParam.whirlSpeed1
			   		end 
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
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,flag.allow_dss+flag.dribbling}
end

function whirlRobotToCarry(role)
	local spdW = function()
		local playerP = player.pos(role)
		local minDis = 9000
		local minDisEnemy = 0
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i) then
				local dist1 = enemy.pos(i):dist(playerP)		
				if dist1 < minDis then
					minDis = dist1
					minDisEnemy = i
				end
			end
		end	
        local b2e =ball.toEnemyDir(minDisEnemy)
	    local b2r = ball.toPlayerDir(role)		
		local subDir = math.abs(b2r-b2e)
		if subDir > whtParam.whirlArcCompare then
			local add = false
			if (b2r * b2e > 0 ) then
				if b2r > 0 then
					if b2r > b2e then
						add = false 
					else
						add = true 
					end 
				else
					if b2r >b2e then
						add = false 
					else
						add = true
					end
				end 
			else
				if b2r > 0 then
					if b2r > b2e + math.pi then
						add = true 
					else
						add = false
					end 
				else
					if b2r >b2e - math.pi then
						add = true
					else
						add = false
					end
				end 
			end 
			if add then
           		if IS_SIMULATION then
					return whtParam.whirlSimulationSpeed
		   		else
					return whtParam.whirlSpeed
		   		end 
			else			
           		if IS_SIMULATION then
					return whtParam.whirlSimulationSpeed1
		   		else
					return whtParam.whirlSpeed1
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
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,flag.allow_dss+flag.dribbling}
end


function aroundBallToRobot(role,role1,dist)
	local ipos = function()		
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
	   		--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end	
			local playerDir =(tempXY-player.pos(role)):dir()
    	local playerToGoal = player.toPlayerDir(role,role1)	
    	if math.abs(playerToGoal-playerDir) > 0.02  then
        -- 通过二者弧度位置,得到顺时针还是逆时针
          if  playerDir < playerToGoal then
         		return  tempXY + Utils.Polar2Vector(dist,dir.ballToPlayer(role)+whtParam.detAngle)
         	else
         		return  tempXY  + Utils.Polar2Vector(dist,dir.ballToPlayer(role)-whtParam.detAngle)
         	end       		
			else
				return player.pos(role)
			end
		end		
	end 
	local idir =function()
		return dir.playerToBall(role)
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
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir,pre.high, specifiedFlat, specifiedChip,f}
end



function CSroundBallToShoot(role,dist)
	local ipos = function()	
		local tempXY =  CGeoPoint:new_local(0,0) 
		local initArc = math.abs(player.toTheirGoalDir(role)-dir.playerToBall(role))
		return function()
			--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
	   		local playerDir =(tempXY - player.pos(role)):dir()
	        local playerToGoal = player.toTheirGoalDir(role)
			local nowArc = math.abs(playerToGoal-playerDir)
			local nowSpeed = nowArc/initArc*whtParam.CSroundBallSpeed
		   	if  playerDir < playerToGoal  then
		   		return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() + math.pi/180*nowSpeed)
		   	else
		   		return  tempXY + Utils.Polar2Vector(dist,(player.pos(role) - tempXY):dir() - math.pi/180*nowSpeed)
		   	end
		end 
	end 
	local idir = dir.playerToBall
	local f = flag.allow_dss +flag.dodge_ball
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end




-- 2.3 射门及传球设计
function shoot(role,chip)
	local pos1 = function()
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
		   	--如果球没有消失且在场内, 保存当前球的位置和弧度，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			return tempXY
		end 			
	end
	local ikick = function()
		if chip then
			return 2
		else
			return 1
		end 
	end
	-- local ikick = chip and kick.chip or kick.flat
	local idir = function()
		local goalPos1 = CGeoPoint:new_local(param.pitchLength/2,param.goalWidth/4)
		local goalPos2 = CGeoPoint:new_local(param.pitchLength/2,-param.goalWidth/4)
		local goalPos = CGeoPoint:new_local(param.pitchLength/2,0)
		local goalDir1 = (goalPos1-ball.pos()):dir()
		local goalDir2 = (goalPos2-ball.pos()):dir()
		local goalDir =	 (goalPos-ball.pos()):dir()
		for i=0,param.maxPlayer-1 do
			if  enemy.valid(i) and  enemy.pos(i):dist(pos.theirGoal()) < param.penaltyRadius then
				local posy = enemy.posY(i)
				if posy  > 100  then 
					goalDir = goalDir2
				elseif posy < -100  then
					goalDir = goalDir1
				elseif ball.posY() < -100 then
					goalDir = goalDir2
				elseif ball.posY() > 100 then
					goalDir = goalDir1
				else
					goalDir = goalDir1
				end  
			end
		end
		return goalDir
	end   
    function specifiedFlat()
	   if IS_SIMULATION then
			return whtParam.simulationMaxPower
	   else
			return whtParam.realMaxPower
	   end 
	end
	function specifiedChip()
		local pw 
		if IS_SIMULATION then
	  		pw =  ( CGeoPoint:new_local(param.pitchLength/2,0):dist(player.pos(role))) * whtParam.simulationChipTimes
			if pw < whtParam.simulationChipMinPower then    
				pw = whtParam.simulationChipMinPower			
			elseif pw > whtParam.simulationChipMaxPower then
				pw = whtParam.simulationChipMaxPower
			end
			return pw
	   else
	  		pw =  ( CGeoPoint:new_local(param.pitchLength/2,0):dist(player.pos(role))) * whtParam.realChipTimes
			if pw < whtParam.realChipMinPower then    
				pw = whtParam.realChipMinPower			
			elseif pw > whtParam.realChipMaxPower then
				pw = whtParam.realChipMaxPower		
			end
			return pw
			-- return 2000
	   end 
	end
	-- 角度对准精度
    function customPre()
		return whtParam.shootPre 
	end
	local mexe, mpos = GoCmuRush{pos = pos1(), dir = idir, acc = a, flag = flag.allow_dss+ flag.dribbling,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, customPre, specifiedFlat, specifiedChip, flag.allow_dss+ flag.dribbling}
end 



function kickBall(role,role1)
		local pos1 = function()
			local tempXY =  CGeoPoint:new_local(0,0) 
			return function()
			   	--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
				if whtFunction.BallInField() then
					tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
				end 
				return tempXY	
			end
		end
		local ikick = function()
			if whtFunction.canFlatPassToRole(role,role1) then
				return 1
			else
				return 2
			end
		end			
		local idir = function()
			return (player.pos(role1) - player.pos(role)):dir()
		end
     
	    function specifiedFlat()
		   local pw 
		   local roleP = player.pos(role)
		   local roleP1 = player.pos(role1)
		   if IS_SIMULATION then
		  		pw =  (roleP:dist(roleP1))*whtParam.simulationTimes + whtParam.simulationCompensate
		  		if pw < whtParam.simulationMinPower then   
					pw = whtParam.simulationMinPower 					
				elseif pw > whtParam.simulationMaxPower then
					pw = whtParam.simulationMaxPower
				end
				return pw
		   else
		  		pw =  (roleP:dist(roleP1))*whtParam.realTimes + whtParam.realCompensate
				if pw < whtParam.realMinPower then    
					pw = whtParam.realMinPower 			
				elseif pw > whtParam.realMaxPower then
					pw = whtParam.realMaxPower
				end
				return pw
				-- return 300
		   end 
		end
		function specifiedChip()
			local pw 
			local roleP = player.pos(role)
		    local roleP1 = player.pos(role1)
			if IS_SIMULATION then
		  		pw =  (roleP:dist(roleP1)) * whtParam.simulationChipTimes
				if pw < whtParam.simulationChipMinPower then    
					pw = whtParam.simulationChipMinPower			
				elseif pw > whtParam.simulationChipMaxPower then
					pw = whtParam.simulationChipMaxPower
				end
				return pw
		   else
		  		pw =  (roleP:dist(roleP1)) * whtParam.realChipTimes
				if pw < whtParam.realChipMinPower then    
					pw = whtParam.realChipMinPower			
				elseif pw > whtParam.realChipMaxPower then
					pw = whtParam.realChipMaxPower		
				end
				return pw
				-- return 2000
		   end 
		end
	local mexe, mpos = GoCmuRush{pos = pos1(), dir = idir, acc = a, flag = flag.allow_dss+ flag.dribbling,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, flag.allow_dss+ flag.dribbling}
end 













--防守技能：
--1.1  守门员		
-- 					goalie(): 平台自带 
-- 					luaGoalie(): 其中二个具体数值需通过实地调试

-- 1.2 后防 
-- 防守球门左区域中点\右区域中点\中心
-- 球消失时使用当前机器人的位置和弧度
-- 当球靠近防守机器人时,主动出机挑射
-- n 为1 左防守,为2 右防守 ,3为中防
--防过设计了二种方式，使用时注释掉一个，建议三机器人使用左右区域联防，只有二个机器人使用集中联防 
-- 					function backDef(role,n) : 三个机器人集中联防 	
--					function backDef(role,n) :三个机器人分左右区域联防,推荐使用

--1.3 协防			
-- 					robotDef(role,n)  参数n表示防守优先级,1为最大
-- 					离我方球门越近优先级越高







--1.3 协防(比赛过程中使用)
-- 防守位置：阻挡接球线
-- n为满足条件的第几个对方机器人: 
-- 如没有满足条件的对方机器人,去准备的位置(跑位)
-- 对方机器人越靠近球门中心,优先级越高
function robotDef(role,n)
	local ipos =function()
		local tempXY =  CGeoPoint:new_local(0,0) 
		return function()
		   	--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			local temp  --进行排序时所用的临时变量
			local sortEnemy = {} --保存对方机器人的编号
			local ourGoal =CGeoPoint:new_local(-param.pitchLength/2,0)
	    	--统计需防守机器人数
			local count = 0
	    	for j = 0, param.maxPlayer-1 do
	            if enemy.valid(j)  and  enemy.pos(j):dist(tempXY) > whtParam.exceptDist1 
	            	and enemy.posX(j) < whtParam.exceptDist2 then	            	
	            	count = count + 1
	            	sortEnemy[count] = j
	            end            
	    	end
		    -- 根据对方机器人和我方球门的中心点距离进行排序(从小到大)
		    if count > 1 then
			    for i = 1,count-1 do 
			        for j =1, count-i do 
			            if enemy.pos(sortEnemy[j]):dist(ourGoal) > enemy.pos(sortEnemy[j+1]):dist(ourGoal) then
			                temp = sortEnemy[j]
			                sortEnemy[j]  = sortEnemy[j+1]
			                sortEnemy[j+1] = temp
			            end
			        end
			    end
			end
			if n  > count  then
				-- 我方防守机器人多的第一个:去跑进攻时的接球位置
				if  n == count+1 then
					return tempXY + Utils.Polar2Vector(600,(ourGoal - tempXY):dir())
				-- 我方防守机器人多的第二个:
				elseif n == count+2 then
					return whtParam.defToAttackStopPos[1]
				-- 我方防守机器人多的第三个
				else
					return whtParam.defToAttackStopPos[2]					
				end 
			-- 防守对应的对方机器人
			else 
				local eP = enemy.pos(sortEnemy[n])
				return eP + Utils.Polar2Vector(whtParam.helpDefDist,(tempXY - eP):dir())       
			end 	    	
		end 
	end	
	local idir = dir.playerToBall
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end



--1.1  守门员	

-- 1.2 后防 
-- function backDef(role,n) 
-- 	-- 三个机器人集中联防
-- 	local newPoint
-- 	if n == 1 then
-- 		 newPoint = CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/4)
-- 	elseif n == 2 then
-- 		 newPoint = CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/4)
-- 	else
-- 		 newPoint = CGeoPoint:new_local(-param.pitchLength/2,0)	
-- 	end
-- 	local pointL = CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth,param.penaltyWidth/2)
-- 	local pointR = CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth,-param.penaltyWidth/2)
-- 	local ipos = function()		
-- 		--保存初始球的状态
-- 		local tempXY =  CGeoPoint:new_local(0,0) --保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
-- 		return function()
-- 			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
-- 			if whtFunction.BallInField() then
-- 				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
-- 			end 
-- 			-- 如果球离防守机器人的距离小于设定值而且球靠近禁区时,返回球的坐标(踢球) 
-- 			if  tempXY:dist(player.pos(role)) < whtParam.autoShootDist and tempXY:x() < -param.pitchLength/3 then
-- 				return tempXY
-- 			-- 在一定位置防守
-- 			else
				
-- 				local idirL = (pointL-newPoint):dir() -- 防守点指向禁区左顶点的弧度
-- 				local idirR = (pointR-newPoint):dir() -- 防守点指向禁区右顶点的弧度
-- 				local idir = (tempXY - newPoint):dir()-- 防守点指向球的弧度
-- 				--左边机器人(防守点是球门左侧中心)
-- 				if n == 1 then
-- 					-- 防守左侧时，返回机器人的位置（150指的是机器人离左侧禁区线的Y方向偏移）
-- 					if  idir > idirL then
-- 						local iLen = math.abs((param.penaltyWidth/2 - param.goalWidth/4 + 150)/math.sin(idir))
-- 					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
-- 						return iPos
-- 					-- 当球移动到右侧区域时，左边防守机器人归位，设定为左侧与正面的交点附件
-- 					-- 当对方左右二边传球进，保证至少有一个机器人来得及防守
-- 					elseif idir < idirR - 0.1 then
-- 						return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,param.penaltyWidth/2 + 100)
-- 					--防守正面（150指的是机器人离正面禁区线的X方向偏移）
-- 					else
-- 					    local iLen = math.abs((param.penaltyDepth + 150)/math.cos(idir))
-- 					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
-- 						return iPos
-- 					end
-- 				--右边机器人(防守点是球门右侧中心)
-- 				elseif n ==2 then
-- 					if  idir < idirR then
-- 						local iLen = math.abs((param.penaltyWidth/2 - param.goalWidth/4 + 150)/math.sin(idir))
-- 					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
-- 						return iPos					
-- 					elseif idir > idirL + 0.1 then
-- 						return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,-param.penaltyWidth/2 - 100)
-- 					else
-- 					    local iLen = math.abs((param.penaltyDepth + 150)/math.cos(idir))
-- 					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
-- 						return iPos
-- 					end
-- 				--中间机器人(防守点是球门中心)
-- 				else					
-- 					--球离底线很近时，中间机器人移动到二侧与正面的交点附件
-- 					if  ball.posX() < -11*param.pitchLength/24 and ball.posY() > 0 then
-- 						return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,param.penaltyWidth/2 + 100)
-- 					elseif ball.posX() < -11*param.pitchLength/24 and ball.posY() < 0 then
-- 						return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,-param.penaltyWidth/2 - 100)
-- 					else
-- 						--防守左侧
-- 						if  idir > idirL then
-- 							newPoint = CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/4)
-- 							idir = (ball.pos() - newPoint):dir()
-- 							local iLen = math.abs((param.penaltyWidth/2 + param.goalWidth/4 + 400)/math.sin(idir))
-- 						    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
-- 							return iPos					
-- 						--防守右侧
-- 						elseif  idir < idirR then
-- 							newPoint = CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/4)
-- 							idir = (ball.pos() - newPoint):dir()
-- 							local iLen = math.abs((param.penaltyWidth/2 + param.goalWidth/4 + 400)/math.sin(idir))
-- 						    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
-- 							return iPos	
-- 						--防守正面
-- 						else
-- 							newPoint = CGeoPoint:new_local(-param.pitchLength/2,0)
-- 							idir = (ball.pos() - newPoint):dir()
-- 						    local iLen = math.abs((param.penaltyDepth + 400)/math.cos(idir))
-- 						    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
-- 							return iPos
-- 						end
-- 					end
-- 				end			
-- 			end
-- 		end
-- 	end 
-- 	local idir =function()
-- 		--保存初始球的状态
-- 		local tempXY =  CGeoPoint:new_local(0,0) --保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
-- 		return function()
-- 			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
-- 			if whtFunction.BallInField() then
-- 				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
-- 			end 
-- 			return (tempXY - player.pos(role)):dir()
-- 		end  
-- 	end
-- 	local ikick = function()
-- 		local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-player.pos(role)):dir()
-- 		local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-player.pos(role)):dir()
-- 		local pDir = player.dir(role)
-- 		--如果球在附近，防守机器人出击踢球
-- 		if  ball.pos():dist(player.pos(role)) < whtParam.autoShootDist then
-- 			--通过机器人与球门二边的连线弧度的正负比较，得出机器人的位置区域，不同区域，使用不同的条件。
-- 			if tempDir1 * tempDir2 >0 then 
-- 				--防止机器人踢向本方球门，只有满足弧度条件下才会踢球解围。
-- 				if pDir < tempDir1 - 0.1 or pDir > tempDir2 + 0.1 then
-- 					return 2
-- 				else
-- 					return 0
-- 				end 
-- 			elseif tempDir1 * tempDir2 <0 then
-- 				if tempDir1 * tempDir2 >0 then
-- 					if pDir < tempDir1 - 0.1 and  pDir > tempDir2 + 0.1 then
-- 						return 2
-- 					else
-- 						return 0
-- 					end 
-- 				end
-- 			else
-- 				return 0
-- 			end 
-- 		else
-- 			return 0
-- 		end 
-- 	end
--     function specifiedFlat()
-- 	   if IS_SIMULATION then
-- 			return whtParam.simulationMaxPower
-- 	   else
-- 			return whtParam.realMaxPower
-- 	   end 
-- 	end
--     function specifiedChip()
-- 		return 2000
-- 	end
-- 	local f = flag.nothing
-- 	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir(), acc = a, flag = f,rec = r,vel = v}
-- 	return {mexe, mpos, ikick, idir(),pre.low, specifiedFlat, specifiedChip,f}
-- end

function backDef(role,n) 
	-- 三个机器人分左右区域联防
	local newPoint
	if n == 1 then
		 newPoint = CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/4)
	elseif n == 2 then
		 newPoint = CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/4)
	else
		 newPoint = CGeoPoint:new_local(-param.pitchLength/2,0)	
	end
	local pointL = CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth,param.penaltyWidth/2)
	local pointR = CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth,-param.penaltyWidth/2)
	
	local ipos = function()		
		--保存初始球的状态
		local tempXY =  CGeoPoint:new_local(0,0) --保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			-- 如果球离防守机器人的距离小于设定值而且球靠近禁区时,返回球的坐标(踢球) 
			if  tempXY:dist(player.pos(role)) < whtParam.autoShootDist and tempXY:x() < -param.pitchLength/3 then
				return tempXY
			-- 在一定位置防守
			else				
				local idirL = (pointL-newPoint):dir() -- 防守点指向禁区左顶点的弧度
				local idirR = (pointR-newPoint):dir() -- 防守点指向禁区右顶点的弧度
				local idir = (tempXY - newPoint):dir()-- 防守点指向球的弧度
				--- 左边防守机器人(防守目标点是左侧中心）
				if n == 1 then
					-- 防守左侧时，返回机器人的位置（150指的是机器人离左侧禁区线的Y方向偏移）
					if  idir > idirL  then
						local iLen = math.abs((param.penaltyWidth/2 - param.goalWidth/4 + 150)/math.sin(idir))
					  local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
						return iPos
					-- 当球移动到右侧区域时，左边防守机器人归位，设定为左侧与正面的交点附件
					-- 当对方左右二边传球进，保证至少有一个机器人来得及防守
					elseif idir <  - 0.1 then
						return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,param.penaltyWidth/2 + 100)
					-- 防守正面左侧时，返回机器人的位置（150指的是机器人离正面禁区线的X方向偏移）
					else
					    local iLen = math.abs((param.penaltyDepth + 150)/math.cos(idir))
					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
							return iPos
					end
				--右边防守机器人，同左边防守机器人(防守目标点是右侧中心）
				elseif n ==2 then
					if  idir < idirR  then
							local iLen = math.abs((param.penaltyWidth/2 - param.goalWidth/4 + 150)/math.sin(idir))
					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
							return iPos					
					elseif idir >  0.1 then
							return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,-param.penaltyWidth/2 - 100)
					else
					    local iLen = math.abs((param.penaltyDepth + 150)/math.cos(idir))
					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
							return iPos
					end
				--中间防守机器人(防守目标点是右侧中心和左侧中心)
				else					
					-- 如果球到了左侧靠近禁区附近，中间防守机器人回撤，防守左侧与正面的交点附件
					if  idir > idirL + 0.6 then
							return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,param.penaltyWidth/2 + 100)				
					-- 防守左侧时，返回机器人的位置(防守的是球门右侧中心)
					elseif idir > idirL  then
							newPoint = CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/4)
							idir = (ball.pos() - newPoint):dir()
							local iLen = math.abs((param.penaltyWidth/2 + param.goalWidth/4 + 400)/math.sin(idir))
					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
							return iPos	
					-- 如果球到了右侧靠近禁区附近，中间防守机器人回撤，防守右侧与正面的交点附件
					elseif  idir < idirR - 0.6 then
							return CGeoPoint:new_local(-param.pitchLength/2+param.penaltyDepth+100,-param.penaltyWidth/2 - 100)
					-- 防守右侧时，返回机器人的位置(防守的是球门左侧中心)
					elseif  idir < idirR  then
							newPoint = CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/4)
							idir = (ball.pos() - newPoint):dir()
							local iLen = math.abs((param.penaltyWidth/2 + param.goalWidth/4 + 400)/math.sin(idir))
					    local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
							return iPos
					-- 防守正面时，返回机器人的位置(防守的是球门左右二侧中心)
					else
						if tempXY:y() > 0 then
							newPoint = CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/4)
							idir = (tempXY - newPoint):dir()
						else
							newPoint = CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/4)
							idir = (tempXY - newPoint):dir()								
						end
					  local iLen = math.abs((param.penaltyDepth + 150)/math.cos(idir))
					  local iPos = newPoint + Utils.Polar2Vector(iLen ,idir)						
						return iPos
					end
				end			
			end
		end
	end 

	local idir =function()
		--保存初始球的状态
		local tempXY =  CGeoPoint:new_local(0,0) --保存当前帧的位置，如球不在场内或消失，保存的是前一帧位置
		return function()
			--如果球没有消失且在场内, 保存当前球的位置，否则使用的是前一帧的值
			if whtFunction.BallInField() then
				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
			end 
			return (tempXY - player.pos(role)):dir()
		end  
	end
	local ikick = function()
		local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-player.pos(role)):dir()
		local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-player.pos(role)):dir()
		local pDir = player.dir(role)
		--如果球在附近，防守机器人出击踢球
		if  ball.pos():dist(player.pos(role)) < whtParam.autoShootDist then
			--通过机器人与球门二边的连线弧度的正负比较，得出机器人的位置区域，不同区域，使用不同的条件。
			if tempDir1 * tempDir2 >0 then 
				--防止机器人踢向本方球门，只有满足弧度条件下才会踢球解围。
				if pDir < tempDir1 - 0.1 or pDir > tempDir2 + 0.1 then
					return 2
				else
					return 0
				end 
			elseif tempDir1 * tempDir2 <0 then
				if tempDir1 * tempDir2 >0 then
					if pDir < tempDir1 - 0.1 and  pDir > tempDir2 + 0.1 then
						return 2
					else
						return 0
					end 
				end
			else
				return 0
			end 
		else
			return 0
		end 
	end
    function specifiedFlat()
	   if IS_SIMULATION then
			return whtParam.simulationMaxPower
	   else
			return whtParam.realMaxPower
	   end 
	end
    function specifiedChip()
		return 2000
	end
	local f = flag.nothing
	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir(), acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir(),pre.low, specifiedFlat, specifiedChip,f}
end







-- 2. 跑位设计		
-- 					runPos(role,n) 	参数n表示第几个机器人,值为1,2,3,4. 1为最高优先传跑位点
--					directRunPos(role,n)   任意球跑位
--					directDefRobotRunPos(role,n)  防守机器人任意球时跑位



--                  passBallToEnemy(role)  直接向最近的对方角色传球(用在无接球角色时)



-- 4. 带球设计		
-- 带球运行的角色必须使用()匹配			
--	circulate值为true 或 false 表示是否循环运行	 
-- 					directBallCarry(role,circulate):	任意球时带球（用在禁区附近带球）
--					centerCarryBall(role,circulate):	中心位置带球 
--					nearOurCarryBall(role,circulate):	靠近我方禁区位置带球 
--					nearLineCarryBall(role,circulate):	边线附近位置带球 




-- 6. 旋转设计	



--6.3 					whirlRobotAroundBallToRobot(role,role1) : 围绕球旋转到传球方向
--6.4 					whirlRobotAroundBallToEnemy(role) : 围绕球旋转到最近敌方的方向
--6.5 					whirlRobotToAdvance(role) :旋转到前进方向(吸球方式)






--8. 防守




-- 8.3  任意球协防
--					robotDirectDef(role,n)：主要需别是排除对方机器人的距离不同，排除太靠近底线的机器人

-- 8.4  守门员		


-- 					goaliePenalty(role)  : 罚球守门员


-- 9. 前进设计  
-- 					advance(role)  :  向前推进
-- 					advance1(role)  :  向前推进(大点球用)




-- 2.1   跑位（比赛过程中的跑位）
function runPos(role,n)
	local ipos =function()	
		if whtFunction.BallInField() then	
			local ballX = ball.posX()
			local ballY = ball.posY()
			local tX 
			local tY
			local temp
			local X
			local staticPos = CGeoPoint:new_local(param.pitchLength/2,0)
			-- 当：X.... 时
			if ballX < -5*param.pitchLength/24 and ballY > 3*param.pitchWidth/18 then
				X = {CGeoPoint:new_local(-2*param.pitchLength/24,2*param.pitchWidth/18),
					CGeoPoint:new_local(2*param.pitchLength/24,7*param.pitchWidth/18),
					CGeoPoint:new_local(-param.pitchLength/24,-6*param.pitchWidth/18)
					}			
				tX = X[1]:x()	
				for i = 0 ,4 do
					tY = X[1]:y()-i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end
				tX = X[2]:x()				
				for i = 0 ,3 do
					 tY = X[2]:y()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[2] =temp
						break
					end 
				end
				for i = 0 ,2 do
					 temp = X[3] +  Utils.Polar2Vector(500,  math.pi/2+i*math.pi/2)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end	
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：Y 时
			elseif ballX < -5*param.pitchLength/24 and ballY < -3*param.pitchWidth/18 then
				X = {CGeoPoint:new_local(-2*param.pitchLength/24,-2*param.pitchWidth/18),
					CGeoPoint:new_local(2*param.pitchLength/24,-7*param.pitchWidth/18),
					CGeoPoint:new_local(-param.pitchLength/24,6*param.pitchWidth/18)
					}			
				tX = X[1]:x()	
				for i = 0 ,4 do
					tY = X[1]:y()+i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end
				tX = X[2]:x()				
				for i = 0 ,3 do
					 tY = X[2]:y()+i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[2] =temp
						break
					end 
				end
				for i = 0 ,2 do
					 temp = X[3] +  Utils.Polar2Vector(500,  -math.pi/2-i*math.pi/2)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end	
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：Z 时	
			elseif ballX < -5*param.pitchLength/24 and ballY > -3*param.pitchWidth/18 and ballY < 3*param.pitchWidth/18 then
				X = {CGeoPoint:new_local(-param.pitchLength/24,6*param.pitchWidth/18),
					CGeoPoint:new_local(-param.pitchLength/24,-6*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,2*param.pitchWidth/18)
					}			
				for i = 0 ,2 do
					 temp = X[1] +  Utils.Polar2Vector(500,  -math.pi/2-i*math.pi/2)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end	
				for i = 0 ,2 do
					 temp = X[2] +  Utils.Polar2Vector(500,  math.pi/2+i*math.pi/2)
					if whtFunction.canBallPassToPos(temp) then
						X[2] =temp
						break
					end 
				end	
				tX = X[3]:x()				
				for i = 0 ,3 do
					 tY = X[3]:y() - i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：1时
			elseif ballX < 0 and ballY > 3*param.pitchWidth/18 then
				X = {CGeoPoint:new_local(8*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,-4*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,2*param.pitchWidth/18)
					}			
				
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  2*math.pi/3+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[1] =temp
						break
					end 
				end	
				
				for i = 0 ,2 do
					 tY = X[2]:y()-i*500	
					 tX = X[2]:x()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[2] =temp
						break
					end 
				end
				tX = X[3]:x()				
				for i = 0 ,4 do
					 tY = X[3]:y() - i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end				
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：2  时		
			elseif ballX < 5*param.pitchLength/24 and ballY > 3*param.pitchWidth/18  then
				X = {CGeoPoint:new_local(7*param.pitchLength/24,2*param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,-5*param.pitchWidth/18)
					}			
				tX = X[1]:x()					
				for i = 0 ,4 do
					tY = X[1]:y() - i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[1] =temp
						break
					end 
				end		
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  2*math.pi/3+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end	
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -2*math.pi/3-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[3] =temp
						break
					end 
				end
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：3 时	
			elseif ballX > 5*param.pitchLength/24 and ballY > 3*param.pitchWidth/18  then
				X = {CGeoPoint:new_local(5*param.pitchLength/24,-param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(2*param.pitchLength/24,7*param.pitchWidth/18)
					}			
				tY = X[1]:y()				
				for i = 0 ,4 do
					 tX = X[1]:x()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end	
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -2*math.pi/3-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end
				tX = X[3]:x()	
				for i = 0 ,3 do
					 tY = X[3]:y()-i*500	
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：4 时	
			elseif ballX > 5*param.pitchLength/24 and ballY > -3*param.pitchWidth/18 and ballY < 3*param.pitchWidth/18 then
				X = {CGeoPoint:new_local(8*param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,2*param.pitchWidth/18)
					}			
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -2*math.pi/3-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[1] =temp
						break
					end 
				end
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  2*math.pi/3+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end
				tX = X[3]:x()				
				for i = 0 ,4 do
					 tY = X[3]:y()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end	
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：5 时	
			elseif ballX > 0 and ballY > -3*param.pitchWidth/18 and ballY < 3*param.pitchWidth/18  then
				X = {CGeoPoint:new_local(8*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(10*param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(7*param.pitchLength/24,2*param.pitchWidth/18)
					}			
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  2*math.pi/3+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[1] =temp
						break
					end 
				end
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -2*math.pi/3-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end
				tX = X[3]:x()				
				for i = 0 ,4 do
					 tY = X[3]:y()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end	
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：6 时	
			elseif ballX < 0 and ballY > -3*param.pitchWidth/18 and ballY < 3*param.pitchWidth/18  then
				X = {CGeoPoint:new_local(8*param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(10*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(7*param.pitchLength/24,2*param.pitchWidth/18)
					}			
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -2*math.pi/3-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[1] =temp
						break
					end 
				end
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  2*math.pi/3+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end
				tX = X[3]:x()				
				for i = 0 ,4 do
					 tY = X[3]:y()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end	
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：7 时	
			elseif ballX < 0 and ballY < -3*param.pitchWidth/18  then
				X = {CGeoPoint:new_local(8*param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(2*param.pitchLength/24,7*param.pitchWidth/18),
					CGeoPoint:new_local(5*param.pitchLength/24,-param.pitchWidth/18)
					}			
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -2*math.pi/3-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[1] =temp
						break
					end 
				end
				tX = X[2]:x()	
				for i = 0 ,3 do
					 tY = X[2]:y()-i*500	
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[2] =temp
						break
					end 
				end
				tY = X[3]:y()				
				for i = 0 ,4 do
					 tX = X[3]:x()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end	
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：8 时	
			elseif ballX < 5*param.pitchLength/24 and ballY < -3*param.pitchWidth/18  then
				X = {CGeoPoint:new_local(7*param.pitchLength/24,2*param.pitchWidth/18),
					CGeoPoint:new_local(10*param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,5*param.pitchWidth/18)
					}			
				tX = X[1]:x()				
				for i = 0 ,4 do
					 tY = X[1]:y()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end	
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -2*math.pi/3-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  2*math.pi/3+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[3] =temp
						break
					end 
				end
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			-- 当：9时
			elseif ballX > 5*param.pitchLength/24 and ballY < -3*param.pitchWidth/18  then
				X = {CGeoPoint:new_local(3*param.pitchLength/24,2*param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,-4*param.pitchWidth/18)
					}			
				
				tX = X[1]:x()				
				for i = 0 ,4 do
					 tY = X[1]:y() - i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  2*math.pi/3+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end	
				
				for i = 0 ,2 do
					 tY = X[3]:y()-i*500	
					 tX = X[3]:x()-i*500
					 temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				else
					return X[3]
				end 
			else
				return player.pos(role)
			end 
		-- 如果球出界
		else
			return player.pos(role)
		end 
	end 
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end

-- 2.2   任意球跑位
function directRunPos(role,n)
	local ipos =function()	
		if whtFunction.BallInField() then	
			local ballX = ball.posX()
			local ballY = ball.posY()
			local tX 
			local tY
			local temp
			local X
			-- 当：ballX < -2*param.pitchLength/24  时
			if ballX < -2*param.pitchLength/24 and ballY > 0 then
				X = {CGeoPoint:new_local(3*param.pitchLength/24,6*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,-param.pitchWidth/18),
					CGeoPoint:new_local(param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,2*param.pitchWidth/18)
					}			
				tX = X[1]:x()	
				for i = 0 ,3 do
					tY = X[1]:y()-i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end	
				tY = X[2]:y()	
				for i = 0 ,4 do
					tX = X[2]:x()-i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[2] =temp
						break
					end 
				end	
				tY = X[3]:y()	
				for i = 0 ,4 do
					tX = X[3]:x()-i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end		
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				elseif n == 3 then
					return X[3]
				else
					return X[4]
				end 
			elseif ballX < -2*param.pitchLength/24 and ballY < 0 then
				X = {CGeoPoint:new_local(3*param.pitchLength/24,-6*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,param.pitchWidth/18),
					CGeoPoint:new_local(param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(3*param.pitchLength/24,-2*param.pitchWidth/18)
					}			
				tX = X[1]:x()	
				for i = 0 ,3 do
					tY = X[1]:y()+i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[1] =temp
						break
					end 
				end	
				tY = X[2]:y()	
				for i = 0 ,4 do
					tX = X[2]:x()-i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[2] =temp
						break
					end 
				end	
				tY = X[3]:y()	
				for i = 0 ,4 do
					tX = X[3]:x()-i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) then
						X[3] =temp
						break
					end 
				end		
				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				elseif n == 3 then
					return X[3]
				else
					return X[4]
				end 

			else
				local staticPos = CGeoPoint:new_local(param.pitchLength/2,0)
				X = {CGeoPoint:new_local(7*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(7*param.pitchLength/24,-5*param.pitchWidth/18),
					CGeoPoint:new_local(5*param.pitchLength/24,2*param.pitchWidth/18),
					CGeoPoint:new_local(4*param.pitchLength/24,-2*param.pitchWidth/18)
					}				
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  5*math.pi/6-math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[1] =temp
						break
					end 
				end					
				for i = 0 ,3 do
					 temp = staticPos +  Utils.Polar2Vector(whtParam.canDirectDist,  -5*math.pi/6+math.pi*10*i/180)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[2] =temp
						break
					end 
				end
				tX = X[3]:x()					
				for i = 0 ,4 do
					tY = X[3]:y() - i*500					
					temp = CGeoPoint:new_local(tX,tY)
					if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
						X[3] =temp
						break
					end 
				end		

				if n == 1 then
					return X[1]
				elseif n == 2 then
					return X[2]
				elseif n == 3 then
					return X[3]
				else
					return X[4]
				end 
			end 
		-- 如果球出界
		else
			return player.pos(role)
		end 
	end 
	local idir = dir.playerToBall
	local f = flag.allow_dss 
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end    

--2.3   防守机器人任意球时跑位
function directDefRobotRunPos(role,n)
	local ipos =function()	
		if whtFunction.BallInField() then	
			local ballX = ball.posX()
			local ballY = ball.posY()
			local temp
			local X 	
			if  ballY > 0 then
				X = {CGeoPoint:new_local(10*param.pitchLength/24,6*param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,-param.pitchWidth/18),
					CGeoPoint:new_local(6*param.pitchLength/24,-5*param.pitchWidth/18)
					}
			else
				X = {CGeoPoint:new_local(6*param.pitchLength/24,5*param.pitchWidth/18),
					CGeoPoint:new_local(8*param.pitchLength/24,param.pitchWidth/18),
					CGeoPoint:new_local(10*param.pitchLength/24,-6*param.pitchWidth/18)
					}
			end				
			
			-- if ballX > -2*param.pitchLength/24 and  ballY < 0 then
			-- 	X = {CGeoPoint:new_local(10*param.pitchLength/24-200,6*param.pitchWidth/18+200),
			-- 		CGeoPoint:new_local(8*param.pitchLength/24,-param.pitchWidth/18),
			-- 		CGeoPoint:new_local(5*param.pitchLength/24,-4*param.pitchWidth/18)
			-- 		}
			-- elseif ballX > -2*param.pitchLength/24 and ballY > 0 then
			-- 	X = {CGeoPoint:new_local(5*param.pitchLength/24,4*param.pitchWidth/18),
			-- 		CGeoPoint:new_local(8*param.pitchLength/24,-param.pitchWidth/18),
			-- 		CGeoPoint:new_local(10*param.pitchLength/24-200,-6*param.pitchWidth/18-200)
			-- 		}
			-- else
			-- 	X = {CGeoPoint:new_local(2*param.pitchLength/24,6*param.pitchWidth/18),
			-- 		CGeoPoint:new_local(3*param.pitchLength/24,-3*param.pitchWidth/18),
			-- 		CGeoPoint:new_local(2*param.pitchLength/24,-6*param.pitchWidth/18)
			-- 		}
			-- end				
			
			for i = 0 ,4 do
				local temp = X[1] + Utils.Polar2Vector(300,i*math.pi/4)
				if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
					X[1] =temp
					break
				end 
			end
			for i = 0 ,4 do
				local temp = X[2] + Utils.Polar2Vector(300,i*math.pi/4)
				if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
					X[2] =temp
					break
				end 
			end
			for i = 0 ,4 do
				local temp = X[3] + Utils.Polar2Vector(300,-math.pi/2 + i*math.pi/4)
				if whtFunction.canBallPassToPos(temp) and whtFunction.canFlatShoot(temp) then
					X[3] =temp
					break
				end 
			end
			if n == 1 then
				return X[1]
			elseif n == 2 then
				return X[2]
			else
				return X[3]
			end 
		-- 如果球出界
		else
			return player.pos(role)
		end 
	end 
	local idir = dir.playerToBall
	local f = flag.allow_dss + flag.dodge_ball
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


-- 3. 传球设计
-- 3.1 任意球发球时使用	
-- function passBall(role,role1)
-- 		local pos1 = function()
-- 			return player.pos(role1)			
-- 		end
-- 		-- local ikick = chip and kick.chip or kick.flat
-- 		local ikick = function()
-- 			if whtFunction.canFlatPassToRole(role,role1) then
-- 				return 1
-- 			else
-- 				return 2
-- 			end
-- 		end		
-- 		local idir = function()
-- 			return (pos1() - player.pos(role)):dir()
-- 		end
   
-- 		local ipos = pos1()     
-- 	    function specifiedFlat()
-- 		   local pw 
-- 		   if IS_SIMULATION then
-- 		  		pw =  (ball.pos():dist(ipos))*whtParam.simulationTimes + whtParam.simulationCompensate
-- 		  		if pw < whtParam.simulationMinPower then   
-- 					pw = whtParam.simulationMinPower 					
-- 				elseif pw > whtParam.simulationMaxPower then
-- 					pw = whtParam.simulationMaxPower
-- 				end
-- 				return pw
-- 		   else
-- 		  		pw =  (ball.pos():dist(ipos))*whtParam.realTimes + whtParam.realCompensate
-- 				if pw < whtParam.realMinPower then    
-- 					pw = whtParam.realMinPower 			
-- 				elseif pw > whtParam.realMaxPower then
-- 					pw = whtParam.realMaxPower
-- 				end
-- 				return pw
-- 				-- return 300
-- 		   end 
-- 		end
-- 		function specifiedChip()
-- 			local pw 
-- 			if IS_SIMULATION then
-- 		  		pw =  (ball.pos():dist(ipos)) * whtParam.simulationChipTimes
-- 				if pw < whtParam.simulationChipMinPower then    
-- 					pw = whtParam.simulationChipMinPower			
-- 				elseif pw > whtParam.simulationChipMaxPower then
-- 					pw = whtParam.simulationChipMaxPower
-- 				end
-- 				return pw
-- 		   else
-- 		  		pw =  (ball.pos():dist(ipos)) * whtParam.realChipTimes
-- 				if pw < whtParam.realChipMinPower then    
-- 					pw = whtParam.realChipMinPower			
-- 				elseif pw > whtParam.realChipMaxPower then
-- 					pw = whtParam.realChipMaxPower		
-- 				end
-- 				return pw
-- 				-- return 2000
-- 		   end 
-- 		end
-- 		f = flag.allow_dss + flag.dodge_ball		
-- 		local mexe, mpos = Touch{pos = pos1}
-- 		-- return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, flag.allow_dss+flag.dribbling}
-- 		return {mexe, mpos, ikick, idir, pre.high, specifiedFlat, specifiedChip, f}
-- end 
function passBall(role,role1)
	local pos1 = function()
		return ball.pos()			
	end
local ikick = function()
		if whtFunction.canFlatPassToRole(role,role1) then
			return 1
		else
			return 2
		end
end	
	local idir = function()
		return (player.pos(role1) - player.pos(role)):dir()
	end

	-- local ipos = pos1()     
    function specifiedFlat()
	   local pw 
	   if IS_SIMULATION then
	  		pw =  (ball.pos():dist(player.pos(role1)))*whtParam.simulationTimes + whtParam.simulationCompensate
	  		if pw < whtParam.simulationMinPower then   
				pw = whtParam.simulationMinPower 					
			elseif pw > whtParam.simulationMaxPower then
				pw = whtParam.simulationMaxPower
			end
			return pw
	   else
	  		pw =  (ball.pos():dist(player.pos(role1)))*whtParam.realTimes + whtParam.realCompensate
			if pw < whtParam.realMinPower then    
				pw = whtParam.realMinPower 			
			elseif pw > whtParam.realMaxPower then
				pw = whtParam.realMaxPower
			end
			return pw
			-- return 300
	   end 
	end
	function specifiedChip()
		local pw 
		if IS_SIMULATION then
	  		pw =  (ball.pos():dist(player.pos(role1))) * whtParam.simulationChipTimes
			if pw < whtParam.simulationChipMinPower then    
				pw = whtParam.simulationChipMinPower			
			elseif pw > whtParam.simulationChipMaxPower then
				pw = whtParam.simulationChipMaxPower
			end
			return pw
	   else
	  		pw =  (ball.pos():dist(player.pos(role1))) * whtParam.realChipTimes
			if pw < whtParam.realChipMinPower then    
				pw = whtParam.realChipMinPower			
			elseif pw > whtParam.realChipMaxPower then
				pw = whtParam.realChipMaxPower		
			end
			return pw
			-- return 2000
	   end 
	end
	local mexe, mpos = GoCmuRush{pos = pos1, dir = idir, acc = 1000, flag = flag.allow_dss,rec = r,vel = v}
	return {mexe, mpos, ikick, idir, pre.high, specifiedFlat, specifiedChip, flag.allow_dss}

end 

-- 3.2  直接向最近的对方角色传球
function passBallToEnemy(role)
		local pos1 = function()			
			local ballP = ball.pos()
			local minDis = 9000
			local minDisEnemy
			for i = 0, param.maxPlayer-1 do
				if enemy.valid(i) then
					local dist1 = enemy.pos(i):dist(ballP)		
					if dist1 < minDis then
						minDis = dist1
						minDisEnemy = i
					end
				end
			end	
		    return enemy.pos(minDisEnemy)
		end
		local ikick = function()
				return 1
		end

		local idir = function()
			return (pos1() - player.pos(role)):dir()
		end   
	    
	    function specifiedFlat()
		   if IS_SIMULATION then
				return whtParam.simulationMaxPower
		   else
				return whtParam.realMaxPower
		   end 
		end
	    function specifiedChip()
			return 0
		end
		f = flag.allow_dss + flag.dodge_ball
		local mexe, mpos = Touch{pos = pos1}
		return {mexe, mpos, ikick, idir, pre.low, specifiedFlat, specifiedChip, f}
end 



-- 4. 带球设计		

--4.1 禁区附近带球(任意球带球)
function directBallCarry(role,circulate)
-- 最靠近的对方抢球机器人
	local enemyN =function()
		local ballP = ball.pos()
		local minDis = 15000
		local minDisEnemy = 0
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i) then
				local dist1 = enemy.pos(i):dist(ballP)		
				if dist1 < minDis then
					minDis = dist1
					minDisEnemy = i
				end
			end
		end	
		return minDisEnemy
	end
	local tempP = CGeoPoint:new_local(param.pitchLength/2,0)

	local p 
	 p = {
		-- 第一点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR  --每次移动500的距离，一个方向最多二次，不超守1米
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			end 
			return  pp  
		end,

		-- 第二点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+2*tempMoveDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-2*tempMoveDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+2*tempMoveDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-2*tempMoveDir)
			end 
			return  pp  
		end,

		-- 第三点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			end 
			return  pp  
		end,
		-- 第四点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			end 
			return  pp  
		end,

		-- 第五点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			end 
			return  pp  
		end,

		-- 第六点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-2*tempMoveDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+2*tempMoveDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+2*tempMoveDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-2*tempMoveDir)
			end 
			return  pp  
		end,

		-- 第七点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir+tempMoveDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir-tempMoveDir)
			end 
			return  pp  
		end,
		-- 第八点
		function ()
			local tempDir = (player.pos(role)- tempP ):dir()
			local tempR = player.pos(role):dist(tempP)
			local tempMoveDir =500/tempR
			local pp			
			if  tempDir > 3*math.pi/4 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			elseif tempDir < -3*math.pi/4  then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			elseif tempDir < 3*math.pi/4 and tempDir > math.pi/2 then
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			else
				pp = tempP + Utils.Polar2Vector(tempR,tempDir)
			end 
			return  pp  
		end,		
	} 
	-- 是否重复运行
    local c = circulate and true or false
    -- 判断是否到达目标点的距离精度
    local d = whtParam.crarryDist 
	local idir = function()
		return enemy.dir(enemyN())		 		
	end    
    local speed = function()
    	if IS_SIMULATION then
    		return whtParam.crarryBallSpeed
     	else 
    		return whtParam.crarryBallSpeed1
    	end 
    end 
    local a = speed()
	-- local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.not_avoid_our_vehicle + flag.dribbling, dist = d, acc = a}
	local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.allow_dss + flag.dribbling, dist = d, acc = a}
	return {mexe, mpos}
end


--4.1 中心位置带球
function centerCarryBall(role,circulate)
-- 最靠近的对方抢球机器人
	local enemyN =function()
		local ballP = ball.pos()
		local minDis = 15000
		local minDisEnemy = 0
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i) then
				local dist1 = enemy.pos(i):dist(ballP)		
				if dist1 < minDis then
					minDis = dist1
					minDisEnemy = i
				end
			end
		end	
		return minDisEnemy
	end

	local p 
	--中心地带运球
	 p = {	
		-- 第一点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir)
			end
			return  pp  
		end,
		-- 第二点
		function ()
    		local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir+math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir-math.pi/4)
			end
			return  pp  
		end,
		-- 第三点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir + 2*math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir- 2*math.pi/4)
			end
			return  pp  
		end,
		-- 第四点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir + 3*math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir- 3*math.pi/4)
			end
			return  pp  
		end,
		-- 第五点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir + 4*math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir- 4*math.pi/4)
			end
			return  pp  
		end,		
		-- 第六点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir + 5*math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir- 5*math.pi/4)
			end
			return  pp  
		end,	
		-- 第七点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir + 6*math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir- 6*math.pi/4)
			end
			return  pp  
		end,
		-- 第八点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -whtParam.crarryDir + 7*math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, whtParam.crarryDir- 7*math.pi/4)
			end
			return  pp  
		end,
		}

	-- 是否重复运行
    local c = circulate and true or false
    -- 判断是否到达目标点的距离精度
    local d = whtParam.crarryDist 
	local idir = function()
		return enemy.dir(enemyN())		 		
	end    
    local speed = function()
    	if IS_SIMULATION then
    		return whtParam.crarryBallSpeed
     	else 
    		return whtParam.crarryBallSpeed1
    	end 
    end 
    local a = speed()
	-- local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.not_avoid_our_vehicle + flag.dribbling, dist = d, acc = a}
	local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.allow_dss + flag.dribbling, dist = d, acc = a}
	return {mexe, mpos}
end


--4.3 已方禁区前带球
function nearOurCarryBall(role,circulate)
-- 最靠近的对方抢球机器人
	local enemyN =function()
		local ballP = ball.pos()
		local minDis = 15000
		local minDisEnemy = 0
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i) then
				local dist1 = enemy.pos(i):dist(ballP)		
				if dist1 < minDis then
					minDis = dist1
					minDisEnemy = i
				end
			end
		end	
		return minDisEnemy
	end

	local p 

	
--已方禁区前运球
	p = {	
		-- 第一点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, 0)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, 0)
			end
			return  pp  
		end,
		-- 第二点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, math.pi/4)
			end
			return  pp  
		end,
		-- 第三点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(200, -math.pi/4)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(200, math.pi/4)
			end
			return  pp  
		end,
		}

	-- 是否重复运行
    local c = circulate and true or false
    -- 判断是否到达目标点的距离精度
    local d = whtParam.crarryDist 
	local idir = function()
		return enemy.dir(enemyN())		 		
	end    
    local speed = function()
    	if IS_SIMULATION then
    		return whtParam.crarryBallSpeed
     	else 
    		return whtParam.crarryBallSpeed1
    	end 
    end 
    local a = speed()
	-- local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.not_avoid_our_vehicle + flag.dribbling, dist = d, acc = a}
	local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.allow_dss + flag.dribbling, dist = d, acc = a}
	return {mexe, mpos}
end

--4.4 边线附近运球
function nearLineCarryBall(role,circulate)
-- 最靠近的对方抢球机器人
	local enemyN =function()
		local ballP = ball.pos()
		local minDis = 15000
		local minDisEnemy = 0
		for i = 0, param.maxPlayer-1 do
			if enemy.valid(i) then
				local dist1 = enemy.pos(i):dist(ballP)		
				if dist1 < minDis then
					minDis = dist1
					minDisEnemy = i
				end
			end
		end	
		return minDisEnemy
	end

	local p 
	--边线附近运球
	p = {	
		-- 第一点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -5*math.pi/6)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, 5*math.pi/6)
			end
			return  pp  
		end,
		-- 第二点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, -math.pi/2)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(whtParam.crarryRadius, math.pi/2)
			end
			return  pp  
		end,
		-- 第三点
		function ()
			local ballY = ball.posY()
			local pp				
			if ballY >0 then
				pp = player.pos(role) + Utils.Polar2Vector(200, -math.pi/2)
			else 
				pp = player.pos(role) + Utils.Polar2Vector(200, math.pi/2)
			end
			return  pp  
		end,
		}

	-- 是否重复运行
    local c = circulate and true or false
    -- 判断是否到达目标点的距离精度
    local d = whtParam.crarryDist 
	local idir = function()
		return enemy.dir(enemyN())		 		
	end    
    local speed = function()
    	if IS_SIMULATION then
    		return whtParam.crarryBallSpeed
     	else 
    		return whtParam.crarryBallSpeed1
    	end 
    end 
    local a = speed()
	-- local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.not_avoid_our_vehicle + flag.dribbling, dist = d, acc = a}
	local mexe, mpos = RunMultiPos{ pos = p, close = c, dir = idir, flag = flag.allow_dss + flag.dribbling, dist = d, acc = a}
	return {mexe, mpos}
end





-- 6. 旋转设计
-- 6.1 旋转到射门方向（吸球方式）

-- 6.2 旋转到传球方向(吸球方式)


-- 6.3 围绕球旋转到传球方向
function whirlRobotAroundBallToRobot(role,role1)
	local ipos = function()		
		if whtFunction.BallInField() then
			local playerDir =dir.playerToBall(role)
        	local playerToGoal = player.toPlayerDir(role,role1)	
        	if math.abs(playerToGoal-playerDir) > whtParam.whirlArcToPassBall  then
            -- 通过二者弧度位置,得到顺时针还是逆时针
	            if  playerDir < playerToGoal then
	           		return  ball.pos() + Utils.Polar2Vector(whtParam.whirlDist,dir.ballToPlayer(role)+whtParam.detAngle)
	           	else
	           		return  ball.pos()  + Utils.Polar2Vector(whtParam.whirlDist,dir.ballToPlayer(role)-whtParam.detAngle)
	           	end       		
			else
				return player.pos(role)
			end			
		else
			return player.pos(role)
		end 

	end 
	local idir =function()
		return dir.playerToBall(role)
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
	local f = flag.allow_dss
	-- a = 1000
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir,pre.high, specifiedFlat, specifiedChip,f}
end

-- 6.4 围绕球旋转到最近敌方的方向
function whirlRobotAroundBallToEnemy(role)
	local ipos = function()		
		if whtFunction.BallInField() then
			local ballP = ball.pos()
			local minDis = 9000
			local minDisEnemy
			for i = 0, param.maxPlayer-1 do
				if enemy.valid(i) then
					local dist1 = enemy.pos(i):dist(ballP)		
					if dist1 < minDis then
						minDis = dist1
						minDisEnemy = i
					end
				end
			end	

			local playerDir =dir.playerToBall(role)
        	local playerToGoal = (enemy.pos(minDisEnemy) - player.pos(role)):dir()
        	if math.abs(playerToGoal-playerDir) > whtParam.whirlArcToPassBall  then
            -- 通过二者弧度位置,得到顺时针还是逆时针
	            if  playerDir < playerToGoal then
	           		return  ball.pos() + Utils.Polar2Vector(whtParam.whirlDist,dir.ballToPlayer(role)+whtParam.detAngle)
	           	else
	           		return  ball.pos()  + Utils.Polar2Vector(whtParam.whirlDist,dir.ballToPlayer(role)-whtParam.detAngle)
	           	end       		
			else
				return player.pos(role)
			end			
		else
			return player.pos(role)
		end 

	end 
	local idir =function()
		return dir.playerToBall(role)
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
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir,pre.high, specifiedFlat, specifiedChip,f}
end

-- 6.5 旋转到前进方向
function whirlRobotToAdvance(role)
	local spdW = function()
		local playerDir =player.dir(role)
		local tempP
        if ball.posY() > 0 then
                tempP = whtParam.advancePoint1
        else
                tempP = whtParam.advancePoint2
        end        
        local playerToGoal = (tempP-player.pos(role)):dir()
        -- 二者弧度相差一定范围内,表示到达目标
        if math.abs(playerToGoal-playerDir) > whtParam.advancePre then
            -- 通过二者弧度位置,得到顺时针还是逆时针
            if  playerDir < playerToGoal then
           		if IS_SIMULATION then
					return whtParam.whirlSimulationSpeed
		   		else
					return whtParam.whirlSpeed
		   		end 
           	else
           		if IS_SIMULATION then
					return whtParam.whirlSimulationSpeed1
		   		else
					return whtParam.whirlSpeed1
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
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,flag.allow_dss+flag.dribbling}
end


-- 6.6 吸球转身








-- 8.3  任意球协防
--主要需别是排除对方机器人的距离不同，排除太靠近底线的机器人
function robotDirectDef(role,n)
	local ipos =function()
		local temp
		local sortEnemy = {} 
		local ourGoal =CGeoPoint:new_local(-param.pitchLength/2,0)
		if whtFunction.BallInField() then			
	    	--统计需防守机器人数
			local count = 0
	    	for j = 0, param.maxPlayer-1 do
	            if enemy.valid(j)  and  enemy.pos(j):dist(ball.pos()) > 2*whtParam.exceptDist1 and enemy.posX(j) > whtParam.exceptDist3 then	            	
	            	count = count + 1
	            	sortEnemy[count] = j
	            end            
	    	end

		    -- 根据对方机器人和我方球门的中心点距离进行排序(从小到大)
		    if count > 1 then
			    for i = 1,count-1 do 
			        for j =1, count-i do 
			            if enemy.pos(sortEnemy[j]):dist(ourGoal) > enemy.pos(sortEnemy[j+1]):dist(ourGoal) then
			                temp = sortEnemy[j]
			                sortEnemy[j]  = sortEnemy[j+1]
			                sortEnemy[j+1] = temp
			            end
			        end
			    end
			end
			if n  > count  then
				if  n == count+1 then
					return ball.pos() + Utils.Polar2Vector(600,(ourGoal - ball.pos()):dir())
				elseif n == count+2 then
					return whtParam.defToAttackStopPos[1]
				else
					return whtParam.defToAttackStopPos[2]					
				end 
			else 
				return enemy.pos(sortEnemy[n]) + Utils.Polar2Vector(whtParam.helpDefDist,(ball.pos() - enemy.pos(sortEnemy[n])):dir())       
			end 	    	
		else
			return player.pos(role)
		end 
	end	
	local idir = dir.playerToBall
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end


-- 8.4  守门


-- function luaGoalie()
-- 	local ipos = function()		
-- 		--保存初始球的位置(前一帧位置)
-- 		local tempXY =  CGeoPoint:new_local(0,0) 
-- 		local tempDir = 0 
-- 		return function(runner)
-- 			--如果球没有消失且在场内, 防守球的位置为当前帧,否则是前一帧的位置
-- 			if whtFunction.BallInField() then
-- 				tempXY = CGeoPoint:new_local(ball.posX(),ball.posY())
-- 				tempDir = ball.velDir()
-- 			end 
-- 			-- 如果球在禁区内,且速度小于某个设定值,守门员出击把球踢出去
-- 			local x = tempXY:x()
-- 			local y = tempXY:y()
-- 			if math.abs(y) < param.penaltyWidth/2 and x < -(param.pitchLength/2 - param.penaltyDepth) 
-- 				and ball.velMod() < whtParam.goalieBallSpeed then
-- 				return tempXY
-- 			--否则, 防守
-- 			else 		
-- 				--判断球的移动弧度延长线与底线的交点在不在球门内,如在,防守垂直点
-- 				--如不在,默认防守球与球门中点的连线
-- 				--球踢出的前5帧，其弧度偏差很大
-- 				local flag = false
-- 				local tempXYy = tempXY:y()
-- 				local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-tempXY):dir()
-- 				local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-tempXY):dir()
-- 				if math.abs(tempXYy) > param.goalWidth/2  then
-- 					if tempDir < tempDir1 + 0.2 and tempDir > tempDir2 - 0.2 then
-- 					    flag = true
-- 					end
-- 				else 
-- 					if tempDir < tempDir1 + 0.1 and tempDir > math.pi  or tempDir > tempDir2 - 0.1  then
-- 					    flag = true
-- 					end					
-- 				end

-- 				if flag then
-- 					local playerP = player.pos(runner)
-- 					local movePoint = tempXY + Utils.Polar2Vector(1000,tempDir)
-- 					local seg = CGeoSegment:new_local(tempXY, movePoint)
-- 					return seg:projection(playerP)	
-- 				else
-- 					local defP = CGeoPoint:new_local(-param.pitchLength/2,0)
-- 					local defP2BallDir =  (tempXY- defP):dir()
-- 					local moveP = defP +  Utils.Polar2Vector(param.goalWidth/2,defP2BallDir)
-- 					local returnX = moveP:x()
-- 					local returnY = moveP:y()
-- 					local minX =  -param.pitchLength/2 + param.playerRadius
-- 					if returnX < minX then
-- 						returnX = minX
-- 					end
-- 					return CGeoPoint:new_local(returnX,returnY)
-- 				end
-- 			end
-- 		end 
-- 	end 
-- 	-- local idir =dir.playerToBall
-- 	local idir =  function(runner)		
-- 		local pDir = (ball.pos()- player.pos(runner)):dir()
-- 		if  whtFunction.BallInOurPenalty() and ball.velMod() < whtParam.goalieBallSpeed  then
-- 			return pDir
-- 		else
-- 			local ballDir = ball.velDir()
-- 			local ballP = ball.pos()
-- 			local ballPY = ball.posY()
-- 			local tempDir1 = (CGeoPoint:new_local(-param.pitchLength/2,-param.goalWidth/2)-ballP):dir()
-- 			local tempDir2 = (CGeoPoint:new_local(-param.pitchLength/2,param.goalWidth/2)-ballP):dir()
-- 			if math.abs(ballPY)  > param.goalWidth/2 then
-- 				if ballDir < tempDir1 and ballDir > tempDir2  then
-- 					 if ballDir > 0 then
-- 					 	pDir = ballDir - math.pi 
-- 					 else
-- 					 	pDir = ballDir + math.pi
-- 					 end 
-- 				end
-- 			end
-- 		end
-- 		return pDir 
-- 	end	
-- 	local ikick = function()
-- 		if  whtFunction.BallInOurPenalty() and ball.velMod() < whtParam.goalieBallSpeed  then
-- 			return 2
-- 		else
-- 			return 0
-- 		end 
-- 	end
--     function specifiedFlat()
-- 			return 0
-- 	end
--     function specifiedChip()
-- 		return 2500
-- 	end
-- 	local f = flag.nothing
-- 	local mexe, mpos = GoCmuRush{pos =ipos(), dir = idir, acc = a, flag = f,rec = r,vel = v}
-- 	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,f}
-- end

-- function goalie(role)
-- 	local ipos = function()		
-- 		if whtFunction.BallInOurPenalty() and ball.velMod() < whtParam.goalieBallSpeed then
-- 			return ball.pos()
-- 		else 
-- 			local iPos =  CGeoPoint:new_local(-param.pitchLength/2 + param.playerRadius,0)
-- 			if ball.posX() < 0  then  --球越过中线
-- 				local tempP= param.goalWidth/2- 80
-- 				-- 防守机器人在球门线上的移动位置（根据球的移动方向移动位置）				
-- 				if ball.velMod() > whtParam.goalieBallSpeed then
-- 				    -- 有球速，判断是不是对方带球旋转，如是，保持防守原位置
-- 				    -- for i=0,param.maxPlayer-1 do
-- 				    --     if  enemy.valid(i) and  enemy.pos(i):dist(ball.pos()) < 110 then
-- 					--         -- return player.pos(role)
-- 					--         return iPos
-- 					--     end
-- 				    -- end
-- 				    if ball.velDir() > 2*math.pi/3 or ball.velDir() < - 2*math.pi/3  then
-- 				    -- 有球速，属于独自移动
-- 					    local idir = ball.velDir()
-- 					    local iLen = math.abs((ball.posX()+param.pitchLength/2 - param.playerRadius)/math.cos(idir))
-- 					    local iPos = ball.pos() + Utils.Polar2Vector(iLen ,idir)
-- 						local posx = - param.pitchLength/2 + param.playerRadius
-- 					    local posy = iPos:y()
-- 					    if posy  > tempP  then 
-- 					        posy = tempP
-- 					    elseif posy < -tempP  then
-- 					        posy = -tempP
-- 					    end  
-- 					    return CGeoPoint:new_local(posx,posy)
-- 					else
-- 						 -- return player.pos(role)
-- 						 return iPos
-- 					end 
-- 				-- 防守机器人在球门线上的移动位置（根据对方的射击角度移动位置）
-- 				else					
-- 				    for i=0,param.maxPlayer-1 do
-- 				        if  enemy.valid(i) and enemy.posX(i) > ball.posX() and enemy.pos(i):dist(ball.pos()) < whtParam.goalieRobotDist then
-- 					        if enemy.dir(i) > 2*math.pi/3 or enemy.dir(i) < - 2*math.pi/3  then
-- 					          	-- local idir = enemy.dir(i)
-- 					          	local idir = (ball.pos()-enemy.pos(i)):dir()
-- 					          	local iLen = math.abs((enemy.posX(i)+param.pitchLength/2 - param.playerRadius)/math.cos(idir))
-- 					          	iPos = enemy.pos(i) + Utils.Polar2Vector(iLen ,enemy.dir(i))
-- 					          	local posx = iPos:x()
-- 					          	local posy = iPos:y()
-- 					          	if posy  > tempP  then 
-- 					            	posy = tempP
-- 					          	elseif posy < -tempP  then
-- 					            	posy = -tempP
-- 					          	end  
-- 					          	return CGeoPoint:new_local(posx,posy)
-- 					        else
-- 					        	-- return player.pos(role)
-- 					        	return iPos
-- 					        end 
-- 				        end
-- 				    end
-- 				    return iPos
-- 				end
-- 			else
-- 				return iPos
-- 			end
-- 		end 
-- 	end 

-- 	local idir =function()
-- 		-- if whtFunction.fieldIncludeOurPenalty() then
-- 			return dir.playerToBall(role)
-- 		-- else
-- 		-- 	return player.dir(role)
-- 		-- end  
-- 	end
-- 	local ikick = function()
-- 		if  whtFunction.BallInOurPenalty() and ball.velMod() < whtParam.goalieBallSpeed  then
-- 			return 2
-- 		else
-- 			return 0
-- 		end 
-- 	end
--     function specifiedFlat()
-- 	   if IS_SIMULATION then
-- 			return whtParam.simulationMaxPower
-- 	   else
-- 			return whtParam.realMaxPower
-- 	   end 
-- 	end
--     function specifiedChip()
-- 		return 2500
-- 	end
-- 	local f = flag.nothing
-- 	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
-- 	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,f}
-- end

-- 8.4   大点球守门
-- 根据双方离球的距离决定是否出击
-- 防守机器人在球门线上的移动位置（根据对方的射击角度移动位置）
-- 防守机器人在球门线上的移动位置（根据球的移动方向移动位置）
function goaliePenalty(role)
	local ipos = function()		
		local tempP= param.goalWidth/2- 80
		if  whtFunction.goalie2Attack() then 	--根据双方离球的距离决定是否出击
			return ball.pos()
		else  
			--根据球的移动方向移动位置
			if ball.velMod() > whtParam.speed2Penalty then
			    local idir = ball.velDir()
			    local iLen = math.abs((ball.posX()+param.pitchLength/2 - param.playerRadius)/math.cos(idir))
			    local iPos = ball.pos() + Utils.Polar2Vector(iLen ,idir)
			    local posx = - param.pitchLength/2 + param.playerRadius
			    local posy = iPos:y()
			    if posy  > tempP  then 
			         posy = tempP
			    elseif posy < -tempP  then
			         posy = -tempP
			    end  
			    return CGeoPoint:new_local(posx,posy)
			else
			    --根据对方的射击角度移动位置
			    local iPos =  CGeoPoint:new_local(-param.pitchLength/2 + param.playerRadius,0)
			    for i=0,param.maxPlayer-1 do
			        if  enemy.valid(i)  and enemy.pos(i):dist(ball.pos()) < 400 then
			        	local idir = enemy.dir(i)
			        	local iLen = math.abs((enemy.posX(i)+param.pitchLength/2 - param.playerRadius)/math.cos(idir))
			        	iPos = enemy.pos(i) + Utils.Polar2Vector(iLen ,idir)
			    		local posx = - param.pitchLength/2 + param.playerRadius
			        	local posy = iPos:y()
			        	if posy  > tempP  then 
			           		posy = tempP
			        	elseif posy < -tempP  then
			            	posy = -tempP
			        	end  
			          	return CGeoPoint:new_local(posx,posy)
			        end
			    end
			    return iPos  --球未动，且对方机器人未接近球准备射门时，返回中点
			end	
		end	
	end 
	local idir =function()
		return dir.playerToBall(role)
	end
	local ikick = function()
		return 1
	end
    function specifiedFlat()
	   if IS_SIMULATION then
			return whtParam.simulationMaxPower
	   else
			return whtParam.realMaxPower
	   end 
	end
    function specifiedChip()
		return 2500
	end
	local f = flag.nothing
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos, ikick, idir,pre.low, specifiedFlat, specifiedChip,f}
end



-- 9 前进设计
function advance(role)
		local pos1 = function()			
			if ball.posY() > 0 then
				return whtParam.advancePoint1
			else
				return whtParam.advancePoint2
			end
		end
		local ikick = function()
			if whtFunction.canFlatAdvance() then
				return 1
			else
				return 2
			end 
		end

		local idir = function()
			return (pos1() - player.pos(role)):dir()
		end   
	    function specifiedFlat()
		   if IS_SIMULATION then
				return whtParam.simulationMinPower
		   else
				return 150
		   end 
		end
	    function specifiedChip()
			if IS_SIMULATION then
				return whtParam.simulationChipMinPower
		   	else
				return whtParam.realChipMinPower
		   	end 
		end
	-- 角度对准精度
	    function customPre()
			return whtParam.advancePre 
		end
		local mexe, mpos = Touch{pos = pos1}
		return {mexe, mpos, ikick, idir, customPre, specifiedFlat, specifiedChip, DSS_FLAG+flag.dribbling}
end 
-- 9 前进设计(大点球用)
function advance1(role)
		local pos1 = function()			
			return whtParam.penaltyAdvanceObjectPoint
		end
		local ikick = function()
			return 1
		end
		local idir = function()
			return (pos1() - player.pos(role)):dir()
		end   
	    function specifiedFlat()
		   if IS_SIMULATION then
				return whtParam.penaltyAdvancePower
		   else
				return whtParam.penaltyAdvanceRealPower
		   end 
		end
	    -- 无用
	    function specifiedChip()
				return 150
		end
	-- 角度对准精度
	    function customPre()
			return whtParam.penaltyAdvancePre * math.pi / 180.0
		end

		local mexe, mpos = Touch{pos = pos1}
		return {mexe, mpos, ikick, idir, customPre, specifiedFlat, specifiedChip, DSS_FLAG}
end 




-- 10. 其它


function continue()
	return {["name"] = "continue"}
end



function goSpeciPos(p, d, f, a) -- 2014-03-26 增加a(加速度参数)
	local idir
	local iflag
	if d ~= nil then
		idir = d
	else
		idir = dir.shoot()
	end

	if f ~= nil then
		iflag = f
	else
		iflag = 0
	end

	local mexe, mpos = SmartGoto{pos = p, dir = idir, flag = iflag, acc = a}
	return {mexe, mpos}
end








-- 以下函数测试专用
function openSpeed(vx,vy,vw,vdir,vmod)	
	local spdX = function()
		return vx
	end

	local spdY = function()
		return vy
	end
	
	local spdW = function()
		return vw
	end
	local mexe, mpos = OpenSpeed{speedX = spdX, speedY = spdY, speedW = spdW,dir=vdir,mod=vmod}
	return {mexe, mpos}
end

function speed(vx,vy,vw,vdir,vmod)	
	local spdX = function()
		return vx
	end

	local spdY = function()
		return vy
	end
	
	local spdW = function()
		return vw
	end
	local mexe, mpos = Speed{speedX = spdX, speedY = spdY, speedW = spdW,dir=vdir,mod=vmod}
	return {mexe, mpos}
end

function speedInRobot(vx,vy,vw,vdir,vmod)	
	local spdX = function()
		return vx
	end

	local spdY = function()
		return vy
	end
	
	local spdW = function()
		return vw
	end
	local mexe, mpos = SpeedInRobot{speedX = spdX, speedY = spdY, speedW = spdW,dir=vdir,mod=vmod}
	return {mexe, mpos}
end





function moveCatchPosition(role)
	local ipos =function()
		local playerP = player.pos(role)
		local temp
		-- for i = 0 ,3 do
		-- 	temp = playerP +  Utils.Polar2Vector(2000,  player.dir(role)+i*0.1)
		-- 	if whtFunction.canBallPassToPos(temp) then
		-- 		return temp
		-- 	end 
		-- end
		temp =  playerP +  Utils.Polar2Vector(2000,  player.dir(role))
		return  temp
	end
	local idir = dir.playerToBall
	local f = flag.allow_dss
	local mexe, mpos = GoCmuRush{pos =ipos, dir = idir, acc = a, flag = f,rec = r,vel = v}
	return {mexe, mpos}
end



IS_TEST_MODE = true
IS_SIMULATION = CGetIsSimulation()
USE_SWITCH = false
USE_AUTO_REFEREE = false
OPPONENT_NAME = "Other"
SAO_ACTION = CGetSettings("Alert/SaoAction","Int")
IS_YELLOW = CGetSettings("ZAlert/IsYellow","Bool")
IS_RIGHT = CGetSettings("ZAlert/IsRight", "Bool")
DEBUG_MATCH = CGetSettings("Debug/RoleMatch","Bool")

gStateFileNameString = string.format(os.date("%Y%m%d%H%M"))



--我在这里面修啊修啊修
--烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫
--烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫
--烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫
--烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫烫


-- gTestPlay = "test1-01"
-- gTestPlay = "test1-02"
-- gTestPlay = "test1-03"
-- gTestPlay = "test1-04"
-- gTestPlay = "test1-05"
-- gTestPlay = "test1-06"
-- gTestPlay = "test1-07"
gTestPlay = "test1-08"
-- gTestPlay = "test1-09"
-- gTestPlay = "test1-10"
-- gTestPlay = "test1-11"
-- gTestPlay = "test1-12"
-- gTestPlay = "test1-13"
-- gTestPlay = "test1-14"
-- gTestPlay = "test1-15"
-- gTestPlay = "test1-16"
-- gTestPlay = "test1-17"
-- gTestPlay = "test1-18"
-- gTestPlay = "test1-19"
-- gTestPlay = "test1-20"
-- gTestPlay = "test1-21"
-- gTestPlay = "test1-22"
-- gTestPlay = "test1-23"
-- gTestPlay = "test1-24"
-- gTestPlay = "test1-25"
-- gTestPlay = "test1-26"
-- gTestPlay = "test1-27"

gRoleFixNum = {
        ["Kicker"]   = {},
        ["Goalie"]   = {0},
        ["Tier"]     = {},
}

-- 用来进行定位球的保持
-- 在考虑智能性时用table来进行配置，用于OurIndirectKick
gOurIndirectTable = {
        -- 在OurIndirectKick控制脚本中可以进行改变的值
        -- 上一次定位球的Cycle
        lastRefCycle = 0
}

gSkill = {
        "SmartGoto",
        "SimpleGoto",
        "RunMultiPos",
        "Stop",
        "Goalie",
        "Touch",
        "OpenSpeed",
        "Speed",
        "GotoMatchPos",
        "GoCmuRush",
        "NoneZeroRush",
        "SpeedInRobot"
}

gRefPlayTable = {
        "Ref/Ref_HaltV1",
        "Ref/Ref_OurTimeoutV1",
        "Ref/GameStop/Ref_StopV1",
        "Ref/GameStop/Ref_StopV2",
-- BallPlacement
        -- "Ref/BallPlacement/Ref_BallPlace2Stop",
-- Penalty
        "Ref/PenaltyDef/Ref_PenaltyDefV1",
        "Ref/PenaltyKick/Ref_PenaltyKickV1",
-- KickOff
        "Ref/KickOffDef/Ref_KickOffDefV1",
        "Ref/KickOff/Ref_KickOffV1",
-- 测试守门员和单个射手任意位置射门        
        -- "Ref/KickOffDef/wht_def_2_1-1",
        -- "Ref/KickOff/wht_2_1_1-1",
        "Ref/KickOffDef/wht_def_2_1-2",
        "Ref/KickOff/wht_2_1_1-2",



-- FreeKickDef
        "Ref/CornerDef/Ref_CornerDefV1",
        "Ref/FrontDef/Ref_FrontDefV1",
        "Ref/MiddleDef/Ref_MiddleDefV1",
        "Ref/BackDef/Ref_BackDefV1",
-- FreeKick
        "Ref/CornerKick/Ref_CornerKickV0",
        "Ref/CornerKick/Ref_CornerKickV1",
        "Ref/CornerKick/Ref_CornerKickV2",
        "Ref/CenterKick/Ref_CenterKickV1",
        "Ref/FrontKick/Ref_FrontKickV1",
        "Ref/MiddleKick/Ref_MiddleKickV1",
        "Ref/BackKick/Ref_BackKickV1",
}

gBayesPlayTable = {
        "Nor/NormalPlayV1",
}

gTestPlayTable = {
        "Test/test1-01",
        "Test/test1-02",
        "Test/test1-03",
        "Test/test1-04",
        "Test/test1-05",
        "Test/test1-06",        
        "Test/test1-07",
        "Test/test1-08",
        "Test/test1-09",
        "Test/test1-10",
        "Test/test1-11",
        "Test/test1-12",
        "Test/test1-13",
        "Test/test1-14",
        "Test/test1-15",
        "Test/test1-16",
        "Test/test1-17",
        "Test/test1-18",
        "Test/test1-19",
        "Test/test1-20",
        "Test/test1-21",
        "Test/test1-22",
        "Test/test1-23",
        "Test/test1-24",
        "Test/test1-25",
        "Test/test1-26",
        -- "Test/test1-27",
        -- "Test/test1-28",
        -- "Test/test1-29",
}

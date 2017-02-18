local n_name, XB = ...

XB.Locale.zhCN = {
  Any = {
    Title = '',
    XB_Show = '输入以下命令显示 '..n_name..'：\n/xb show',
    ON = '已启用',
    OFF = '已禁用'
  },
  Keybindings = {
    MasterToggle = '开启/关闭 '..n_name,
    Interrupts = '开启/关闭自动打断',
    Cooldowns = '开启/关闭自动使用CD技能',
    CooldownsOnBoss = '开启/关闭仅在BOSS战中使用CD技能',
    AoE = '开启/关闭AOE模式',
  },
  mainframe = {
    MasterToggle = '鼠标左键：启用/禁用\n鼠标右键：查看设置',
    Interrupts = '开启/关闭自动打断',
    Cooldowns = '开启/关闭自动使用CD技能',
    CooldownsOnBoss = '开启:仅在BOSS战中使用CD技能\n关闭:卡CD使用CD技能\n|cfffff569该设置仅在Cooldowns生效时生效|r',
    AoE = '开启/关闭AOE模式',
    Settings = '设置',
    HideXB = '隐藏 NerdPack',
    ChangeCR = '设置战斗脚本为：',
    Donate = '捐助',
    Forum = '访问我们的论坛',
    CRS = '战斗脚本',
    CRS_ST = '战斗脚本设置'
  },
  Settings = {
    combat = '战斗',
    ui = '界面',
    option = '设置',
    bsize = '按钮大小',
    bpad = '按钮间距',
    apply_bt = '应用',
    auto_target = "自动选择目标"
  },
  OM = {
    Option = '单位列表',
    Enemy = '敌对',
    EnemyVerify = '敌对*',
    Friendly = '友方',
    Dead = '死亡',
    Title = '单位列表',
  },
  AL = {
    Option = '技能使用记录',
    Action = '动作',
    Description = '说明',
    Time = '时间',
    SpellCastSucceed = '成功施放技能',
  },
  Shadow = {
    Abiliteis = '一般技能',
    BaS = '身心合一',
    SwpT = '暗言术:痛 目标上限',
    VtT = '吸血鬼之触 目标上限',
    ShadowCrash = '暗影冲撞',
    S2MCheck = '自杀秒数',
    ActiveEnemies = '激活目标',
    CD = 'CD技能',
    CD_S2M = 'CD技能（S2M）',
    PowerInfusion = '能量灌注',
    ShadowMend = '暗影恶魔',
  }
}

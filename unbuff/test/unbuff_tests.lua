dofile('../../_lib/tosunit.lua');
dofile('../../_lib/yyutil.lua');

dofile('../src/unbuff.lua');

local g = _G.ADDONS.YYU.UNBUFF;
local yyutil = _G.ADDONS.YYU.Util;

local TESTS = tosunit();

TESTS.setup(UNBUFF_ON_INIT);

TESTS.add('TRACE ON/OFF Switch', function()
	assert(g.getBuffID == g.getBuffIDTraceOff);
	yyutil.UI_CHAT_HOOKED('/unbuff traceon');
	assert(g.getBuffID == g.getBuffIDTraceOn);
	yyutil.UI_CHAT_HOOKED('/unbuff traceoff');
	assert(g.getBuffID == g.getBuffIDTraceOff);
end);

TESTS.add('buff���Ȃ���Ԃ̃e�X�g', function()
	assert(g.hasBuff(3070) == false, 'Expect No Levitation buff');
	assert(g.getBuffIDTraceOff({ ClassID = 3070 }) == nil, 'Expect No Skill ID');
	yyutil.UI_CHAT_HOOKED('/unbuff levitation');
end);

TESTS.add('buff(3070=���r�e�[�V����)�ǉ��� /unbuff le �ł̉����̃e�X�g', function()
	session.__handle.addBuff(3070);
	assert(g.hasBuff(3070) == true, 'Levitation buff must exists');
	assert(g.getBuffIDTraceOff({ ClassID = 21107 }) == 3070, 'Must get buffID');

	assert(g.hasBuff(3038) == false, 'Summoning buff must not exist');

	-- �`���b�g�R�}���h�Ń��r�e�[�V�������폜
	yyutil.UI_CHAT_HOOKED('/unbuff le');
	assert(g.hasBuff(3070) == false, 'Expect No Levitation buff');
	assert(g.getBuffIDTraceOff({ ClassID = 21107 }) == nil, 'Expect No Skill ID');
end)

TESTS.add('/unbuff <BUFF ID>', function()
	session.__handle.addBuff(7777);
	assert(g.hasBuff(7777) == true, 'Buff ID 7777 must exist');
	yyutil.UI_CHAT_HOOKED('/unbuff 7777');
	assert(g.hasBuff(7777) == false, 'Buff ID 7777 must not exist');
end);

TESTS.run();

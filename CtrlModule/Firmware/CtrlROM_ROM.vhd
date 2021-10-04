-- ZPU
--
-- Copyright 2004-2008 oharboe - �yvind Harboe - oyvind.harboe@zylin.com
-- Modified by Alastair M. Robinson for the ZPUFlex project.
--
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.zpupkg.all;

entity CtrlROM_ROM is
generic
	(
		maxAddrBitBRAM : integer := maxAddrBitBRAMLimit -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_zpu : in ZPU_ToROM;
	to_zpu : out ZPU_FromROM
);
end CtrlROM_ROM;

architecture arch of CtrlROM_ROM is

type ram_type is array(natural range 0 to ((2**(maxAddrBitBRAM+1))/4)-1) of std_logic_vector(wordSize-1 downto 0);

shared variable ram : ram_type :=
(
     0 => x"0b0b0b0b",
     1 => x"8c0b0b0b",
     2 => x"0b81e004",
     3 => x"0b0b0b0b",
     4 => x"8c04ff0d",
     5 => x"80040400",
     6 => x"00000016",
     7 => x"00000000",
     8 => x"0b0b0bad",
     9 => x"bc080b0b",
    10 => x"0badc008",
    11 => x"0b0b0bad",
    12 => x"c4080b0b",
    13 => x"0b0b9808",
    14 => x"2d0b0b0b",
    15 => x"adc40c0b",
    16 => x"0b0badc0",
    17 => x"0c0b0b0b",
    18 => x"adbc0c04",
    19 => x"00000000",
    20 => x"00000000",
    21 => x"00000000",
    22 => x"00000000",
    23 => x"00000000",
    24 => x"71fd0608",
    25 => x"72830609",
    26 => x"81058205",
    27 => x"832b2a83",
    28 => x"ffff0652",
    29 => x"0471fc06",
    30 => x"08728306",
    31 => x"09810583",
    32 => x"05101010",
    33 => x"2a81ff06",
    34 => x"520471fd",
    35 => x"060883ff",
    36 => x"ff738306",
    37 => x"09810582",
    38 => x"05832b2b",
    39 => x"09067383",
    40 => x"ffff0673",
    41 => x"83060981",
    42 => x"05820583",
    43 => x"2b0b2b07",
    44 => x"72fc060c",
    45 => x"51510471",
    46 => x"fc06080b",
    47 => x"0b0ba7bc",
    48 => x"73830610",
    49 => x"10050806",
    50 => x"7381ff06",
    51 => x"73830609",
    52 => x"81058305",
    53 => x"1010102b",
    54 => x"0772fc06",
    55 => x"0c515104",
    56 => x"adbc70b2",
    57 => x"e0278b38",
    58 => x"80717084",
    59 => x"05530c81",
    60 => x"e2048c51",
    61 => x"88e20402",
    62 => x"fc050df8",
    63 => x"80518f0b",
    64 => x"adcc0c9f",
    65 => x"0badd00c",
    66 => x"a0717081",
    67 => x"055334ad",
    68 => x"d008ff05",
    69 => x"add00cad",
    70 => x"d0088025",
    71 => x"eb38adcc",
    72 => x"08ff05ad",
    73 => x"cc0cadcc",
    74 => x"088025d7",
    75 => x"38800bad",
    76 => x"d00c800b",
    77 => x"adcc0c02",
    78 => x"84050d04",
    79 => x"02f0050d",
    80 => x"f88053f8",
    81 => x"a05483bf",
    82 => x"52737081",
    83 => x"05553351",
    84 => x"70737081",
    85 => x"055534ff",
    86 => x"12527180",
    87 => x"25eb38fb",
    88 => x"c0539f52",
    89 => x"a0737081",
    90 => x"055534ff",
    91 => x"12527180",
    92 => x"25f23802",
    93 => x"90050d04",
    94 => x"02f4050d",
    95 => x"74538e0b",
    96 => x"adcc0825",
    97 => x"8f3882bc",
    98 => x"2dadcc08",
    99 => x"ff05adcc",
   100 => x"0c82fe04",
   101 => x"adcc08ad",
   102 => x"d0085351",
   103 => x"728a2e09",
   104 => x"8106b738",
   105 => x"7151719f",
   106 => x"24a038ad",
   107 => x"cc08a029",
   108 => x"11f88011",
   109 => x"5151a071",
   110 => x"34add008",
   111 => x"8105add0",
   112 => x"0cadd008",
   113 => x"519f7125",
   114 => x"e238800b",
   115 => x"add00cad",
   116 => x"cc088105",
   117 => x"adcc0c83",
   118 => x"ee0470a0",
   119 => x"2912f880",
   120 => x"11515172",
   121 => x"7134add0",
   122 => x"088105ad",
   123 => x"d00cadd0",
   124 => x"08a02e09",
   125 => x"81068e38",
   126 => x"800badd0",
   127 => x"0cadcc08",
   128 => x"8105adcc",
   129 => x"0c028c05",
   130 => x"0d0402e8",
   131 => x"050d7779",
   132 => x"5656880b",
   133 => x"fc167771",
   134 => x"2c8f0654",
   135 => x"52548053",
   136 => x"72722595",
   137 => x"387153fb",
   138 => x"e0145187",
   139 => x"71348114",
   140 => x"ff145454",
   141 => x"72f13871",
   142 => x"53f91576",
   143 => x"712c8706",
   144 => x"53517180",
   145 => x"2e8b38fb",
   146 => x"e0145171",
   147 => x"71348114",
   148 => x"54728e24",
   149 => x"95388f73",
   150 => x"3153fbe0",
   151 => x"1451a071",
   152 => x"348114ff",
   153 => x"14545472",
   154 => x"f1380298",
   155 => x"050d0402",
   156 => x"ec050d80",
   157 => x"0badd40c",
   158 => x"f68c08f6",
   159 => x"90087188",
   160 => x"2c565481",
   161 => x"ff065273",
   162 => x"72258838",
   163 => x"7154820b",
   164 => x"add40c72",
   165 => x"882c7381",
   166 => x"ff065455",
   167 => x"7473258b",
   168 => x"3872add4",
   169 => x"088407ad",
   170 => x"d40c5573",
   171 => x"842b86a0",
   172 => x"71258371",
   173 => x"31700b0b",
   174 => x"0babac0c",
   175 => x"81712bff",
   176 => x"05f6880c",
   177 => x"fdfc13ff",
   178 => x"122c7888",
   179 => x"29ff9405",
   180 => x"70812cad",
   181 => x"d4085258",
   182 => x"52555152",
   183 => x"5476802e",
   184 => x"85387081",
   185 => x"075170f6",
   186 => x"940c7109",
   187 => x"8105f680",
   188 => x"0c720981",
   189 => x"05f6840c",
   190 => x"0294050d",
   191 => x"0402f405",
   192 => x"0d745372",
   193 => x"70810554",
   194 => x"80f52d52",
   195 => x"71802e89",
   196 => x"38715182",
   197 => x"f82d8683",
   198 => x"04810bad",
   199 => x"bc0c028c",
   200 => x"050d0402",
   201 => x"fc050d81",
   202 => x"808051c0",
   203 => x"115170fb",
   204 => x"38028405",
   205 => x"0d0402fc",
   206 => x"050d84bf",
   207 => x"5186a32d",
   208 => x"ff115170",
   209 => x"8025f638",
   210 => x"0284050d",
   211 => x"0402fc05",
   212 => x"0dec5183",
   213 => x"710c86a3",
   214 => x"2d82710c",
   215 => x"0284050d",
   216 => x"0402fc05",
   217 => x"0dec5192",
   218 => x"710c86a3",
   219 => x"2d82710c",
   220 => x"0284050d",
   221 => x"0402d005",
   222 => x"0d7d5480",
   223 => x"5ba40bec",
   224 => x"0c7352ad",
   225 => x"d851a48e",
   226 => x"2dadbc08",
   227 => x"7b2e81ab",
   228 => x"38addc08",
   229 => x"70f80c89",
   230 => x"1580f52d",
   231 => x"8a1680f5",
   232 => x"2d718280",
   233 => x"29058817",
   234 => x"80f52d70",
   235 => x"84808029",
   236 => x"12f40c7e",
   237 => x"ff155c5e",
   238 => x"57555658",
   239 => x"767b2e8b",
   240 => x"38811a77",
   241 => x"812a585a",
   242 => x"76f738f7",
   243 => x"1a5a815b",
   244 => x"80782580",
   245 => x"e6387952",
   246 => x"7651848a",
   247 => x"2daea452",
   248 => x"add851a6",
   249 => x"c42dadbc",
   250 => x"08802eb8",
   251 => x"38aea45c",
   252 => x"83fc597b",
   253 => x"7084055d",
   254 => x"087081ff",
   255 => x"0671882a",
   256 => x"7081ff06",
   257 => x"73902a70",
   258 => x"81ff0675",
   259 => x"982ae80c",
   260 => x"e80c58e8",
   261 => x"0c57e80c",
   262 => x"fc1a5a53",
   263 => x"788025d3",
   264 => x"3888ab04",
   265 => x"adbc085b",
   266 => x"848058ad",
   267 => x"d851a697",
   268 => x"2dfc8018",
   269 => x"81185858",
   270 => x"87d00486",
   271 => x"b62d840b",
   272 => x"ec0c7a80",
   273 => x"2e8d38ab",
   274 => x"b0518f9e",
   275 => x"2d8da12d",
   276 => x"88d904ac",
   277 => x"c8518f9e",
   278 => x"2d7aadbc",
   279 => x"0c02b005",
   280 => x"0d0402ec",
   281 => x"050d840b",
   282 => x"ec0c8d89",
   283 => x"2d89f32d",
   284 => x"81f72d9d",
   285 => x"dd2dadbc",
   286 => x"08802e80",
   287 => x"e13886f5",
   288 => x"51a7b62d",
   289 => x"abb0518f",
   290 => x"9e2d8da1",
   291 => x"2d89ff2d",
   292 => x"8fae2dab",
   293 => x"dc0b80f5",
   294 => x"2d70852b",
   295 => x"a006abe8",
   296 => x"0b80f52d",
   297 => x"70108606",
   298 => x"abf40b80",
   299 => x"f52d7083",
   300 => x"2b980674",
   301 => x"730707ac",
   302 => x"800b80f5",
   303 => x"2d708d2b",
   304 => x"80c08006",
   305 => x"7207fc0c",
   306 => x"53545257",
   307 => x"57535386",
   308 => x"52adbc08",
   309 => x"83388452",
   310 => x"71ec0c89",
   311 => x"8d04800b",
   312 => x"adbc0c02",
   313 => x"94050d04",
   314 => x"71980c04",
   315 => x"ffb008ad",
   316 => x"bc0c0481",
   317 => x"0bffb00c",
   318 => x"04800bff",
   319 => x"b00c0402",
   320 => x"f4050d8b",
   321 => x"8104adbc",
   322 => x"0881f02e",
   323 => x"09810689",
   324 => x"38810bad",
   325 => x"ac0c8b81",
   326 => x"04adbc08",
   327 => x"81e02e09",
   328 => x"81068938",
   329 => x"810badb0",
   330 => x"0c8b8104",
   331 => x"adbc0852",
   332 => x"adb00880",
   333 => x"2e8838ad",
   334 => x"bc088180",
   335 => x"05527184",
   336 => x"2c728f06",
   337 => x"5353adac",
   338 => x"08802e99",
   339 => x"38728429",
   340 => x"acec0572",
   341 => x"1381712b",
   342 => x"70097308",
   343 => x"06730c51",
   344 => x"53538af7",
   345 => x"04728429",
   346 => x"acec0572",
   347 => x"1383712b",
   348 => x"72080772",
   349 => x"0c535380",
   350 => x"0badb00c",
   351 => x"800badac",
   352 => x"0cade451",
   353 => x"8c822dad",
   354 => x"bc08ff24",
   355 => x"fef83880",
   356 => x"0badbc0c",
   357 => x"028c050d",
   358 => x"0402f805",
   359 => x"0dacec52",
   360 => x"8f518072",
   361 => x"70840554",
   362 => x"0cff1151",
   363 => x"708025f2",
   364 => x"38028805",
   365 => x"0d0402f0",
   366 => x"050d7551",
   367 => x"89f92d70",
   368 => x"822cfc06",
   369 => x"acec1172",
   370 => x"109e0671",
   371 => x"0870722a",
   372 => x"70830682",
   373 => x"742b7009",
   374 => x"7406760c",
   375 => x"54515657",
   376 => x"53515389",
   377 => x"f32d71ad",
   378 => x"bc0c0290",
   379 => x"050d0402",
   380 => x"fc050d72",
   381 => x"5180710c",
   382 => x"800b8412",
   383 => x"0c028405",
   384 => x"0d0402f0",
   385 => x"050d7570",
   386 => x"08841208",
   387 => x"535353ff",
   388 => x"5471712e",
   389 => x"a83889f9",
   390 => x"2d841308",
   391 => x"70842914",
   392 => x"88117008",
   393 => x"7081ff06",
   394 => x"84180881",
   395 => x"11870684",
   396 => x"1a0c5351",
   397 => x"55515151",
   398 => x"89f32d71",
   399 => x"5473adbc",
   400 => x"0c029005",
   401 => x"0d0402f8",
   402 => x"050d89f9",
   403 => x"2de00870",
   404 => x"8b2a7081",
   405 => x"06515252",
   406 => x"70802e9d",
   407 => x"38ade408",
   408 => x"708429ad",
   409 => x"ec057381",
   410 => x"ff06710c",
   411 => x"5151ade4",
   412 => x"08811187",
   413 => x"06ade40c",
   414 => x"51800bae",
   415 => x"8c0c89ec",
   416 => x"2d89f32d",
   417 => x"0288050d",
   418 => x"0402fc05",
   419 => x"0dade451",
   420 => x"8bef2d8b",
   421 => x"992d8cc6",
   422 => x"5189e82d",
   423 => x"0284050d",
   424 => x"0402fc05",
   425 => x"0d8dab04",
   426 => x"89ff2d80",
   427 => x"f6518bb6",
   428 => x"2dadbc08",
   429 => x"f33880da",
   430 => x"518bb62d",
   431 => x"adbc08e8",
   432 => x"38adbc08",
   433 => x"adb80cad",
   434 => x"bc085184",
   435 => x"ef2d0284",
   436 => x"050d0402",
   437 => x"ec050d76",
   438 => x"54805287",
   439 => x"0b881580",
   440 => x"f52d5653",
   441 => x"74722483",
   442 => x"38a05372",
   443 => x"5182f82d",
   444 => x"81128b15",
   445 => x"80f52d54",
   446 => x"52727225",
   447 => x"de380294",
   448 => x"050d0402",
   449 => x"f0050dae",
   450 => x"90085481",
   451 => x"f72d800b",
   452 => x"ae940c73",
   453 => x"08802e81",
   454 => x"8038820b",
   455 => x"add00cae",
   456 => x"94088f06",
   457 => x"adcc0c73",
   458 => x"08527183",
   459 => x"2e963871",
   460 => x"83268938",
   461 => x"71812eaf",
   462 => x"388f8404",
   463 => x"71852e9f",
   464 => x"388f8404",
   465 => x"881480f5",
   466 => x"2d841508",
   467 => x"aa805354",
   468 => x"5285fd2d",
   469 => x"71842913",
   470 => x"70085252",
   471 => x"8f880473",
   472 => x"518dd32d",
   473 => x"8f8404ad",
   474 => x"b4088815",
   475 => x"082c7081",
   476 => x"06515271",
   477 => x"802e8738",
   478 => x"aa84518f",
   479 => x"8104aa88",
   480 => x"5185fd2d",
   481 => x"84140851",
   482 => x"85fd2dae",
   483 => x"94088105",
   484 => x"ae940c8c",
   485 => x"14548e93",
   486 => x"04029005",
   487 => x"0d0471ae",
   488 => x"900c8e83",
   489 => x"2dae9408",
   490 => x"ff05ae98",
   491 => x"0c0402e8",
   492 => x"050dae90",
   493 => x"08ae9c08",
   494 => x"57558751",
   495 => x"8bb62dad",
   496 => x"bc08812a",
   497 => x"70810651",
   498 => x"5271802e",
   499 => x"a0388fd4",
   500 => x"0489ff2d",
   501 => x"87518bb6",
   502 => x"2dadbc08",
   503 => x"f438adb8",
   504 => x"08813270",
   505 => x"adb80c70",
   506 => x"525284ef",
   507 => x"2d80fe51",
   508 => x"8bb62dad",
   509 => x"bc08802e",
   510 => x"a638adb8",
   511 => x"08802e91",
   512 => x"38800bad",
   513 => x"b80c8051",
   514 => x"84ef2d90",
   515 => x"910489ff",
   516 => x"2d80fe51",
   517 => x"8bb62dad",
   518 => x"bc08f338",
   519 => x"86e12dad",
   520 => x"b8089038",
   521 => x"81fd518b",
   522 => x"b62d81fa",
   523 => x"518bb62d",
   524 => x"95e40481",
   525 => x"f5518bb6",
   526 => x"2dadbc08",
   527 => x"812a7081",
   528 => x"06515271",
   529 => x"802eaf38",
   530 => x"ae980852",
   531 => x"71802e89",
   532 => x"38ff12ae",
   533 => x"980c90f6",
   534 => x"04ae9408",
   535 => x"10ae9408",
   536 => x"05708429",
   537 => x"16515288",
   538 => x"1208802e",
   539 => x"8938ff51",
   540 => x"88120852",
   541 => x"712d81f2",
   542 => x"518bb62d",
   543 => x"adbc0881",
   544 => x"2a708106",
   545 => x"51527180",
   546 => x"2eb138ae",
   547 => x"9408ff11",
   548 => x"ae980856",
   549 => x"53537372",
   550 => x"25893881",
   551 => x"14ae980c",
   552 => x"91bb0472",
   553 => x"10137084",
   554 => x"29165152",
   555 => x"88120880",
   556 => x"2e8938fe",
   557 => x"51881208",
   558 => x"52712d81",
   559 => x"fd518bb6",
   560 => x"2dadbc08",
   561 => x"812a7081",
   562 => x"06515271",
   563 => x"802ead38",
   564 => x"ae980880",
   565 => x"2e893880",
   566 => x"0bae980c",
   567 => x"91fc04ae",
   568 => x"940810ae",
   569 => x"94080570",
   570 => x"84291651",
   571 => x"52881208",
   572 => x"802e8938",
   573 => x"fd518812",
   574 => x"0852712d",
   575 => x"81fa518b",
   576 => x"b62dadbc",
   577 => x"08812a70",
   578 => x"81065152",
   579 => x"71802eae",
   580 => x"38ae9408",
   581 => x"ff115452",
   582 => x"ae980873",
   583 => x"25883872",
   584 => x"ae980c92",
   585 => x"be047110",
   586 => x"12708429",
   587 => x"16515288",
   588 => x"1208802e",
   589 => x"8938fc51",
   590 => x"88120852",
   591 => x"712dae98",
   592 => x"08705354",
   593 => x"73802e8a",
   594 => x"388c15ff",
   595 => x"15555592",
   596 => x"c404820b",
   597 => x"add00c71",
   598 => x"8f06adcc",
   599 => x"0c81eb51",
   600 => x"8bb62dad",
   601 => x"bc08812a",
   602 => x"70810651",
   603 => x"5271802e",
   604 => x"ad387408",
   605 => x"852e0981",
   606 => x"06a43888",
   607 => x"1580f52d",
   608 => x"ff055271",
   609 => x"881681b7",
   610 => x"2d71982b",
   611 => x"52718025",
   612 => x"8838800b",
   613 => x"881681b7",
   614 => x"2d74518d",
   615 => x"d32d81f4",
   616 => x"518bb62d",
   617 => x"adbc0881",
   618 => x"2a708106",
   619 => x"51527180",
   620 => x"2eb33874",
   621 => x"08852e09",
   622 => x"8106aa38",
   623 => x"881580f5",
   624 => x"2d810552",
   625 => x"71881681",
   626 => x"b72d7181",
   627 => x"ff068b16",
   628 => x"80f52d54",
   629 => x"52727227",
   630 => x"87387288",
   631 => x"1681b72d",
   632 => x"74518dd3",
   633 => x"2d80da51",
   634 => x"8bb62dad",
   635 => x"bc08812a",
   636 => x"70810651",
   637 => x"5271802e",
   638 => x"81a638ae",
   639 => x"9008ae98",
   640 => x"08555373",
   641 => x"802e8a38",
   642 => x"8c13ff15",
   643 => x"55539483",
   644 => x"04720852",
   645 => x"71822ea6",
   646 => x"38718226",
   647 => x"89387181",
   648 => x"2ea93895",
   649 => x"a0047183",
   650 => x"2eb13871",
   651 => x"842e0981",
   652 => x"0680ed38",
   653 => x"88130851",
   654 => x"8f9e2d95",
   655 => x"a004ae98",
   656 => x"08518813",
   657 => x"0852712d",
   658 => x"95a00481",
   659 => x"0b881408",
   660 => x"2badb408",
   661 => x"32adb40c",
   662 => x"94f60488",
   663 => x"1380f52d",
   664 => x"81058b14",
   665 => x"80f52d53",
   666 => x"54717424",
   667 => x"83388054",
   668 => x"73881481",
   669 => x"b72d8e83",
   670 => x"2d95a004",
   671 => x"7508802e",
   672 => x"a2387508",
   673 => x"518bb62d",
   674 => x"adbc0881",
   675 => x"06527180",
   676 => x"2e8b38ae",
   677 => x"98085184",
   678 => x"16085271",
   679 => x"2d881656",
   680 => x"75da3880",
   681 => x"54800bad",
   682 => x"d00c738f",
   683 => x"06adcc0c",
   684 => x"a05273ae",
   685 => x"98082e09",
   686 => x"81069838",
   687 => x"ae9408ff",
   688 => x"05743270",
   689 => x"09810570",
   690 => x"72079f2a",
   691 => x"91713151",
   692 => x"51535371",
   693 => x"5182f82d",
   694 => x"8114548e",
   695 => x"7425c638",
   696 => x"adb80852",
   697 => x"71adbc0c",
   698 => x"0298050d",
   699 => x"0402f405",
   700 => x"0dd45281",
   701 => x"ff720c71",
   702 => x"085381ff",
   703 => x"720c7288",
   704 => x"2b83fe80",
   705 => x"06720870",
   706 => x"81ff0651",
   707 => x"525381ff",
   708 => x"720c7271",
   709 => x"07882b72",
   710 => x"087081ff",
   711 => x"06515253",
   712 => x"81ff720c",
   713 => x"72710788",
   714 => x"2b720870",
   715 => x"81ff0672",
   716 => x"07adbc0c",
   717 => x"5253028c",
   718 => x"050d0402",
   719 => x"f4050d74",
   720 => x"767181ff",
   721 => x"06d40c53",
   722 => x"53aea008",
   723 => x"85387189",
   724 => x"2b527198",
   725 => x"2ad40c71",
   726 => x"902a7081",
   727 => x"ff06d40c",
   728 => x"5171882a",
   729 => x"7081ff06",
   730 => x"d40c5171",
   731 => x"81ff06d4",
   732 => x"0c72902a",
   733 => x"7081ff06",
   734 => x"d40c51d4",
   735 => x"087081ff",
   736 => x"06515182",
   737 => x"b8bf5270",
   738 => x"81ff2e09",
   739 => x"81069438",
   740 => x"81ff0bd4",
   741 => x"0cd40870",
   742 => x"81ff06ff",
   743 => x"14545151",
   744 => x"71e53870",
   745 => x"adbc0c02",
   746 => x"8c050d04",
   747 => x"02fc050d",
   748 => x"81c75181",
   749 => x"ff0bd40c",
   750 => x"ff115170",
   751 => x"8025f438",
   752 => x"0284050d",
   753 => x"0402f405",
   754 => x"0d81ff0b",
   755 => x"d40c9353",
   756 => x"805287fc",
   757 => x"80c15196",
   758 => x"bb2dadbc",
   759 => x"088b3881",
   760 => x"ff0bd40c",
   761 => x"815397f2",
   762 => x"0497ac2d",
   763 => x"ff135372",
   764 => x"df3872ad",
   765 => x"bc0c028c",
   766 => x"050d0402",
   767 => x"ec050d81",
   768 => x"0baea00c",
   769 => x"8454d008",
   770 => x"708f2a70",
   771 => x"81065151",
   772 => x"5372f338",
   773 => x"72d00c97",
   774 => x"ac2daa8c",
   775 => x"5185fd2d",
   776 => x"d008708f",
   777 => x"2a708106",
   778 => x"51515372",
   779 => x"f338810b",
   780 => x"d00cb153",
   781 => x"805284d4",
   782 => x"80c05196",
   783 => x"bb2dadbc",
   784 => x"08812e93",
   785 => x"3872822e",
   786 => x"bd38ff13",
   787 => x"5372e538",
   788 => x"ff145473",
   789 => x"ffb03897",
   790 => x"ac2d83aa",
   791 => x"52849c80",
   792 => x"c85196bb",
   793 => x"2dadbc08",
   794 => x"812e0981",
   795 => x"06923895",
   796 => x"ed2dadbc",
   797 => x"0883ffff",
   798 => x"06537283",
   799 => x"aa2e9d38",
   800 => x"97c52d99",
   801 => x"9704aa98",
   802 => x"5185fd2d",
   803 => x"80539ae5",
   804 => x"04aab051",
   805 => x"85fd2d80",
   806 => x"549ab704",
   807 => x"81ff0bd4",
   808 => x"0cb15497",
   809 => x"ac2d8fcf",
   810 => x"53805287",
   811 => x"fc80f751",
   812 => x"96bb2dad",
   813 => x"bc0855ad",
   814 => x"bc08812e",
   815 => x"0981069b",
   816 => x"3881ff0b",
   817 => x"d40c820a",
   818 => x"52849c80",
   819 => x"e95196bb",
   820 => x"2dadbc08",
   821 => x"802e8d38",
   822 => x"97ac2dff",
   823 => x"135372c9",
   824 => x"389aaa04",
   825 => x"81ff0bd4",
   826 => x"0cadbc08",
   827 => x"5287fc80",
   828 => x"fa5196bb",
   829 => x"2dadbc08",
   830 => x"b13881ff",
   831 => x"0bd40cd4",
   832 => x"085381ff",
   833 => x"0bd40c81",
   834 => x"ff0bd40c",
   835 => x"81ff0bd4",
   836 => x"0c81ff0b",
   837 => x"d40c7286",
   838 => x"2a708106",
   839 => x"76565153",
   840 => x"729538ad",
   841 => x"bc08549a",
   842 => x"b7047382",
   843 => x"2efee238",
   844 => x"ff145473",
   845 => x"feed3873",
   846 => x"aea00c73",
   847 => x"8b388152",
   848 => x"87fc80d0",
   849 => x"5196bb2d",
   850 => x"81ff0bd4",
   851 => x"0cd00870",
   852 => x"8f2a7081",
   853 => x"06515153",
   854 => x"72f33872",
   855 => x"d00c81ff",
   856 => x"0bd40c81",
   857 => x"5372adbc",
   858 => x"0c029405",
   859 => x"0d0402e8",
   860 => x"050d7855",
   861 => x"805681ff",
   862 => x"0bd40cd0",
   863 => x"08708f2a",
   864 => x"70810651",
   865 => x"515372f3",
   866 => x"3882810b",
   867 => x"d00c81ff",
   868 => x"0bd40c77",
   869 => x"5287fc80",
   870 => x"d15196bb",
   871 => x"2d80dbc6",
   872 => x"df54adbc",
   873 => x"08802e8a",
   874 => x"38aad051",
   875 => x"85fd2d9c",
   876 => x"850481ff",
   877 => x"0bd40cd4",
   878 => x"087081ff",
   879 => x"06515372",
   880 => x"81fe2e09",
   881 => x"81069d38",
   882 => x"80ff5395",
   883 => x"ed2dadbc",
   884 => x"08757084",
   885 => x"05570cff",
   886 => x"13537280",
   887 => x"25ed3881",
   888 => x"569bea04",
   889 => x"ff145473",
   890 => x"c93881ff",
   891 => x"0bd40c81",
   892 => x"ff0bd40c",
   893 => x"d008708f",
   894 => x"2a708106",
   895 => x"51515372",
   896 => x"f33872d0",
   897 => x"0c75adbc",
   898 => x"0c029805",
   899 => x"0d0402e8",
   900 => x"050d7779",
   901 => x"7b585555",
   902 => x"80537276",
   903 => x"25a33874",
   904 => x"70810556",
   905 => x"80f52d74",
   906 => x"70810556",
   907 => x"80f52d52",
   908 => x"5271712e",
   909 => x"86388151",
   910 => x"9cc30481",
   911 => x"13539c9a",
   912 => x"04805170",
   913 => x"adbc0c02",
   914 => x"98050d04",
   915 => x"02ec050d",
   916 => x"76557480",
   917 => x"2ebb389a",
   918 => x"1580e02d",
   919 => x"51a79a2d",
   920 => x"adbc08ad",
   921 => x"bc08b2d0",
   922 => x"0cadbc08",
   923 => x"5454b2ac",
   924 => x"08802e99",
   925 => x"38941580",
   926 => x"e02d51a7",
   927 => x"9a2dadbc",
   928 => x"08902b83",
   929 => x"fff00a06",
   930 => x"70750751",
   931 => x"5372b2d0",
   932 => x"0cb2d008",
   933 => x"5372802e",
   934 => x"9938b2a4",
   935 => x"08fe1471",
   936 => x"29b2b808",
   937 => x"05b2d40c",
   938 => x"70842bb2",
   939 => x"b00c549d",
   940 => x"d804b2bc",
   941 => x"08b2d00c",
   942 => x"b2c008b2",
   943 => x"d40cb2ac",
   944 => x"08802e8a",
   945 => x"38b2a408",
   946 => x"842b539d",
   947 => x"d404b2c4",
   948 => x"08842b53",
   949 => x"72b2b00c",
   950 => x"0294050d",
   951 => x"0402d805",
   952 => x"0d800bb2",
   953 => x"ac0c8454",
   954 => x"97fb2dad",
   955 => x"bc08802e",
   956 => x"9538aea4",
   957 => x"5280519a",
   958 => x"ee2dadbc",
   959 => x"08802e86",
   960 => x"38fe549e",
   961 => x"8e04ff14",
   962 => x"54738024",
   963 => x"db38738c",
   964 => x"38aae051",
   965 => x"85fd2d73",
   966 => x"55a39704",
   967 => x"8056810b",
   968 => x"b2d80c88",
   969 => x"53aaf452",
   970 => x"aeda519c",
   971 => x"8e2dadbc",
   972 => x"08762e09",
   973 => x"81068738",
   974 => x"adbc08b2",
   975 => x"d80c8853",
   976 => x"ab8052ae",
   977 => x"f6519c8e",
   978 => x"2dadbc08",
   979 => x"8738adbc",
   980 => x"08b2d80c",
   981 => x"b2d80880",
   982 => x"2e80f638",
   983 => x"b1ea0b80",
   984 => x"f52db1eb",
   985 => x"0b80f52d",
   986 => x"71982b71",
   987 => x"902b07b1",
   988 => x"ec0b80f5",
   989 => x"2d70882b",
   990 => x"7207b1ed",
   991 => x"0b80f52d",
   992 => x"7107b2a2",
   993 => x"0b80f52d",
   994 => x"b2a30b80",
   995 => x"f52d7188",
   996 => x"2b07535f",
   997 => x"54525a56",
   998 => x"57557381",
   999 => x"abaa2e09",
  1000 => x"81068d38",
  1001 => x"7551a6ea",
  1002 => x"2dadbc08",
  1003 => x"569fbd04",
  1004 => x"7382d4d5",
  1005 => x"2e8738ab",
  1006 => x"8c519ffe",
  1007 => x"04aea452",
  1008 => x"75519aee",
  1009 => x"2dadbc08",
  1010 => x"55adbc08",
  1011 => x"802e83c7",
  1012 => x"388853ab",
  1013 => x"8052aef6",
  1014 => x"519c8e2d",
  1015 => x"adbc0889",
  1016 => x"38810bb2",
  1017 => x"ac0ca084",
  1018 => x"048853aa",
  1019 => x"f452aeda",
  1020 => x"519c8e2d",
  1021 => x"adbc0880",
  1022 => x"2e8a38ab",
  1023 => x"a05185fd",
  1024 => x"2da0de04",
  1025 => x"b2a20b80",
  1026 => x"f52d5473",
  1027 => x"80d52e09",
  1028 => x"810680ca",
  1029 => x"38b2a30b",
  1030 => x"80f52d54",
  1031 => x"7381aa2e",
  1032 => x"098106ba",
  1033 => x"38800bae",
  1034 => x"a40b80f5",
  1035 => x"2d565474",
  1036 => x"81e92e83",
  1037 => x"38815474",
  1038 => x"81eb2e8c",
  1039 => x"38805573",
  1040 => x"752e0981",
  1041 => x"0682d038",
  1042 => x"aeaf0b80",
  1043 => x"f52d5574",
  1044 => x"8d38aeb0",
  1045 => x"0b80f52d",
  1046 => x"5473822e",
  1047 => x"86388055",
  1048 => x"a39704ae",
  1049 => x"b10b80f5",
  1050 => x"2d70b2a4",
  1051 => x"0cff05b2",
  1052 => x"a80caeb2",
  1053 => x"0b80f52d",
  1054 => x"aeb30b80",
  1055 => x"f52d5876",
  1056 => x"05778280",
  1057 => x"290570b2",
  1058 => x"b40caeb4",
  1059 => x"0b80f52d",
  1060 => x"70b2c80c",
  1061 => x"b2ac0859",
  1062 => x"57587680",
  1063 => x"2e81a338",
  1064 => x"8853ab80",
  1065 => x"52aef651",
  1066 => x"9c8e2dad",
  1067 => x"bc0881e7",
  1068 => x"38b2a408",
  1069 => x"70842bb2",
  1070 => x"b00c70b2",
  1071 => x"c40caec9",
  1072 => x"0b80f52d",
  1073 => x"aec80b80",
  1074 => x"f52d7182",
  1075 => x"802905ae",
  1076 => x"ca0b80f5",
  1077 => x"2d708480",
  1078 => x"802912ae",
  1079 => x"cb0b80f5",
  1080 => x"2d708180",
  1081 => x"0a291270",
  1082 => x"b2cc0cb2",
  1083 => x"c8087129",
  1084 => x"b2b40805",
  1085 => x"70b2b80c",
  1086 => x"aed10b80",
  1087 => x"f52daed0",
  1088 => x"0b80f52d",
  1089 => x"71828029",
  1090 => x"05aed20b",
  1091 => x"80f52d70",
  1092 => x"84808029",
  1093 => x"12aed30b",
  1094 => x"80f52d70",
  1095 => x"982b81f0",
  1096 => x"0a067205",
  1097 => x"70b2bc0c",
  1098 => x"fe117e29",
  1099 => x"7705b2c0",
  1100 => x"0c525952",
  1101 => x"43545e51",
  1102 => x"5259525d",
  1103 => x"575957a3",
  1104 => x"9004aeb6",
  1105 => x"0b80f52d",
  1106 => x"aeb50b80",
  1107 => x"f52d7182",
  1108 => x"80290570",
  1109 => x"b2b00c70",
  1110 => x"a02983ff",
  1111 => x"0570892a",
  1112 => x"70b2c40c",
  1113 => x"aebb0b80",
  1114 => x"f52daeba",
  1115 => x"0b80f52d",
  1116 => x"71828029",
  1117 => x"0570b2cc",
  1118 => x"0c7b7129",
  1119 => x"1e70b2c0",
  1120 => x"0c7db2bc",
  1121 => x"0c7305b2",
  1122 => x"b80c555e",
  1123 => x"51515555",
  1124 => x"80519ccc",
  1125 => x"2d815574",
  1126 => x"adbc0c02",
  1127 => x"a8050d04",
  1128 => x"02ec050d",
  1129 => x"7670872c",
  1130 => x"7180ff06",
  1131 => x"555654b2",
  1132 => x"ac088a38",
  1133 => x"73882c74",
  1134 => x"81ff0654",
  1135 => x"55aea452",
  1136 => x"b2b40815",
  1137 => x"519aee2d",
  1138 => x"adbc0854",
  1139 => x"adbc0880",
  1140 => x"2eb338b2",
  1141 => x"ac08802e",
  1142 => x"98387284",
  1143 => x"29aea405",
  1144 => x"70085253",
  1145 => x"a6ea2dad",
  1146 => x"bc08f00a",
  1147 => x"0653a483",
  1148 => x"047210ae",
  1149 => x"a4057080",
  1150 => x"e02d5253",
  1151 => x"a79a2dad",
  1152 => x"bc085372",
  1153 => x"5473adbc",
  1154 => x"0c029405",
  1155 => x"0d0402cc",
  1156 => x"050d7e60",
  1157 => x"5e5a800b",
  1158 => x"b2d008b2",
  1159 => x"d408595c",
  1160 => x"568058b2",
  1161 => x"b008782e",
  1162 => x"81ae3877",
  1163 => x"8f06a017",
  1164 => x"5754738f",
  1165 => x"38aea452",
  1166 => x"76518117",
  1167 => x"579aee2d",
  1168 => x"aea45680",
  1169 => x"7680f52d",
  1170 => x"56547474",
  1171 => x"2e833881",
  1172 => x"547481e5",
  1173 => x"2e80f638",
  1174 => x"81707506",
  1175 => x"555c7380",
  1176 => x"2e80ea38",
  1177 => x"8b1680f5",
  1178 => x"2d980659",
  1179 => x"7880de38",
  1180 => x"8b537c52",
  1181 => x"75519c8e",
  1182 => x"2dadbc08",
  1183 => x"80cf389c",
  1184 => x"160851a6",
  1185 => x"ea2dadbc",
  1186 => x"08841b0c",
  1187 => x"9a1680e0",
  1188 => x"2d51a79a",
  1189 => x"2dadbc08",
  1190 => x"adbc0888",
  1191 => x"1c0cadbc",
  1192 => x"085555b2",
  1193 => x"ac08802e",
  1194 => x"98389416",
  1195 => x"80e02d51",
  1196 => x"a79a2dad",
  1197 => x"bc08902b",
  1198 => x"83fff00a",
  1199 => x"06701651",
  1200 => x"5473881b",
  1201 => x"0c787a0c",
  1202 => x"7b54a68e",
  1203 => x"04811858",
  1204 => x"b2b00878",
  1205 => x"26fed438",
  1206 => x"b2ac0880",
  1207 => x"2eae387a",
  1208 => x"51a3a02d",
  1209 => x"adbc08ad",
  1210 => x"bc0880ff",
  1211 => x"fffff806",
  1212 => x"555b7380",
  1213 => x"fffffff8",
  1214 => x"2e9238ad",
  1215 => x"bc08fe05",
  1216 => x"b2a40829",
  1217 => x"b2b80805",
  1218 => x"57a4a104",
  1219 => x"805473ad",
  1220 => x"bc0c02b4",
  1221 => x"050d0402",
  1222 => x"f4050d74",
  1223 => x"70088105",
  1224 => x"710c7008",
  1225 => x"b2a80806",
  1226 => x"5353718e",
  1227 => x"38881308",
  1228 => x"51a3a02d",
  1229 => x"adbc0888",
  1230 => x"140c810b",
  1231 => x"adbc0c02",
  1232 => x"8c050d04",
  1233 => x"02f0050d",
  1234 => x"75881108",
  1235 => x"fe05b2a4",
  1236 => x"0829b2b8",
  1237 => x"08117208",
  1238 => x"b2a80806",
  1239 => x"05795553",
  1240 => x"54549aee",
  1241 => x"2d029005",
  1242 => x"0d0402f4",
  1243 => x"050d7470",
  1244 => x"882a83fe",
  1245 => x"80067072",
  1246 => x"982a0772",
  1247 => x"882b87fc",
  1248 => x"80800673",
  1249 => x"982b81f0",
  1250 => x"0a067173",
  1251 => x"0707adbc",
  1252 => x"0c565153",
  1253 => x"51028c05",
  1254 => x"0d0402f8",
  1255 => x"050d028e",
  1256 => x"0580f52d",
  1257 => x"74882b07",
  1258 => x"7083ffff",
  1259 => x"06adbc0c",
  1260 => x"51028805",
  1261 => x"0d0471b2",
  1262 => x"dc0c0400",
  1263 => x"00ffffff",
  1264 => x"ff00ffff",
  1265 => x"ffff00ff",
  1266 => x"ffffff00",
  1267 => x"20202020",
  1268 => x"203d4c79",
  1269 => x"6e783438",
  1270 => x"3d202020",
  1271 => x"20200000",
  1272 => x"20202020",
  1273 => x"4e657572",
  1274 => x"6f52756c",
  1275 => x"657a2020",
  1276 => x"20200000",
  1277 => x"52657365",
  1278 => x"74000000",
  1279 => x"45786974",
  1280 => x"00000000",
  1281 => x"4a6f7973",
  1282 => x"7469636b",
  1283 => x"20537761",
  1284 => x"70204e6f",
  1285 => x"00000000",
  1286 => x"4a6f7973",
  1287 => x"7469636b",
  1288 => x"20537761",
  1289 => x"70205965",
  1290 => x"73000000",
  1291 => x"4d616368",
  1292 => x"696e6520",
  1293 => x"4c796e78",
  1294 => x"2034384b",
  1295 => x"00000000",
  1296 => x"4d616368",
  1297 => x"696e6520",
  1298 => x"4c796e78",
  1299 => x"2039364b",
  1300 => x"00000000",
  1301 => x"4d616368",
  1302 => x"696e6520",
  1303 => x"39364b20",
  1304 => x"53636f72",
  1305 => x"70696f6e",
  1306 => x"00000000",
  1307 => x"5363616e",
  1308 => x"646f7562",
  1309 => x"6c657246",
  1310 => x"78204e6f",
  1311 => x"6e650000",
  1312 => x"5363616e",
  1313 => x"646f7562",
  1314 => x"6c657246",
  1315 => x"78204851",
  1316 => x"32780000",
  1317 => x"5363616e",
  1318 => x"646f7562",
  1319 => x"6c657246",
  1320 => x"78204352",
  1321 => x"54203235",
  1322 => x"25000000",
  1323 => x"5363616e",
  1324 => x"646f7562",
  1325 => x"6c657246",
  1326 => x"78204352",
  1327 => x"54203530",
  1328 => x"25000000",
  1329 => x"41737065",
  1330 => x"63742052",
  1331 => x"6174696f",
  1332 => x"20343a33",
  1333 => x"00000000",
  1334 => x"41737065",
  1335 => x"63742052",
  1336 => x"6174696f",
  1337 => x"2031363a",
  1338 => x"39000000",
  1339 => x"43617267",
  1340 => x"61204661",
  1341 => x"6c6c6964",
  1342 => x"61000000",
  1343 => x"4f4b0000",
  1344 => x"16200000",
  1345 => x"14200000",
  1346 => x"15200000",
  1347 => x"53442069",
  1348 => x"6e69742e",
  1349 => x"2e2e0a00",
  1350 => x"53442063",
  1351 => x"61726420",
  1352 => x"72657365",
  1353 => x"74206661",
  1354 => x"696c6564",
  1355 => x"210a0000",
  1356 => x"53444843",
  1357 => x"20657272",
  1358 => x"6f72210a",
  1359 => x"00000000",
  1360 => x"57726974",
  1361 => x"65206661",
  1362 => x"696c6564",
  1363 => x"0a000000",
  1364 => x"52656164",
  1365 => x"20666169",
  1366 => x"6c65640a",
  1367 => x"00000000",
  1368 => x"43617264",
  1369 => x"20696e69",
  1370 => x"74206661",
  1371 => x"696c6564",
  1372 => x"0a000000",
  1373 => x"46415431",
  1374 => x"36202020",
  1375 => x"00000000",
  1376 => x"46415433",
  1377 => x"32202020",
  1378 => x"00000000",
  1379 => x"4e6f2070",
  1380 => x"61727469",
  1381 => x"74696f6e",
  1382 => x"20736967",
  1383 => x"0a000000",
  1384 => x"42616420",
  1385 => x"70617274",
  1386 => x"0a000000",
  1387 => x"00000002",
  1388 => x"00000002",
  1389 => x"000013cc",
  1390 => x"00000000",
  1391 => x"00000002",
  1392 => x"000013e0",
  1393 => x"00000000",
  1394 => x"00000002",
  1395 => x"000013f4",
  1396 => x"0000034d",
  1397 => x"00000003",
  1398 => x"00001640",
  1399 => x"00000002",
  1400 => x"00000003",
  1401 => x"00001630",
  1402 => x"00000004",
  1403 => x"00000003",
  1404 => x"00001624",
  1405 => x"00000003",
  1406 => x"00000003",
  1407 => x"0000161c",
  1408 => x"00000002",
  1409 => x"00000002",
  1410 => x"000013fc",
  1411 => x"000006a1",
  1412 => x"00000000",
  1413 => x"00000000",
  1414 => x"00000000",
  1415 => x"00001404",
  1416 => x"00001418",
  1417 => x"0000142c",
  1418 => x"00001440",
  1419 => x"00001454",
  1420 => x"0000146c",
  1421 => x"00001480",
  1422 => x"00001494",
  1423 => x"000014ac",
  1424 => x"000014c4",
  1425 => x"000014d8",
  1426 => x"00000004",
  1427 => x"000014ec",
  1428 => x"00001648",
  1429 => x"00000004",
  1430 => x"000014fc",
  1431 => x"000015b0",
  1432 => x"00000000",
  1433 => x"00000000",
  1434 => x"00000000",
  1435 => x"00000000",
  1436 => x"00000000",
  1437 => x"00000000",
  1438 => x"00000000",
  1439 => x"00000000",
  1440 => x"00000000",
  1441 => x"00000000",
  1442 => x"00000000",
  1443 => x"00000000",
  1444 => x"00000000",
  1445 => x"00000000",
  1446 => x"00000000",
  1447 => x"00000000",
  1448 => x"00000000",
  1449 => x"00000000",
  1450 => x"00000000",
  1451 => x"00000000",
  1452 => x"00000000",
  1453 => x"00000000",
  1454 => x"00000000",
	others => x"00000000"
);

begin

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memAWriteEnable = '1') and (from_zpu.memBWriteEnable = '1') and (from_zpu.memAAddr=from_zpu.memBAddr) and (from_zpu.memAWrite/=from_zpu.memBWrite) then
			report "write collision" severity failure;
		end if;
	
		if (from_zpu.memAWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBitBRAM downto 2)))) := from_zpu.memAWrite;
			to_zpu.memARead <= from_zpu.memAWrite;
		else
			to_zpu.memARead <= ram(to_integer(unsigned(from_zpu.memAAddr(maxAddrBitBRAM downto 2))));
		end if;
	end if;
end process;

process (clk)
begin
	if (clk'event and clk = '1') then
		if (from_zpu.memBWriteEnable = '1') then
			ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBitBRAM downto 2)))) := from_zpu.memBWrite;
			to_zpu.memBRead <= from_zpu.memBWrite;
		else
			to_zpu.memBRead <= ram(to_integer(unsigned(from_zpu.memBAddr(maxAddrBitBRAM downto 2))));
		end if;
	end if;
end process;


end arch;

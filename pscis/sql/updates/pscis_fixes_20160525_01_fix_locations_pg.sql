-- FIX LOCATIONS OF PSCIS STREAM CROSSING LOCATIONS

-- In the initial data load, locations were garbled for these 2008 Masse crossings
-- (locations for a different project were used, resulting in two crossing records per site)
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 513445, utm_northing = 5504222, geom = utmzen2bcalb(11, 513445, 5504222) WHERE stream_crossing_id = 375;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 515525, utm_northing = 5506075, geom = utmzen2bcalb(11, 515525, 5506075) WHERE stream_crossing_id = 376;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 520572, utm_northing = 5506591, geom = utmzen2bcalb(11, 520572, 5506591) WHERE stream_crossing_id = 378;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 522160, utm_northing = 5504476, geom = utmzen2bcalb(11, 522160, 5504476) WHERE stream_crossing_id = 379;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 524942, utm_northing = 5511575, geom = utmzen2bcalb(11, 524942, 5511575) WHERE stream_crossing_id = 380;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 524752, utm_northing = 5510550, geom = utmzen2bcalb(11, 524752, 5510550) WHERE stream_crossing_id = 381;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 523832, utm_northing = 5509480, geom = utmzen2bcalb(11, 523832, 5509480) WHERE stream_crossing_id = 382;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 496849, utm_northing = 5609936, geom = utmzen2bcalb(11, 496849, 5609936) WHERE stream_crossing_id = 385;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 505622, utm_northing = 5580928, geom = utmzen2bcalb(11, 505622, 5580928) WHERE stream_crossing_id = 386;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 499882, utm_northing = 5601699, geom = utmzen2bcalb(11, 499882, 5601699) WHERE stream_crossing_id = 389;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 589595, utm_northing = 5432744, geom = utmzen2bcalb(11, 589595, 5432744) WHERE stream_crossing_id = 392;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 589846, utm_northing = 5429543, geom = utmzen2bcalb(11, 589846, 5429543) WHERE stream_crossing_id = 394;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 590768, utm_northing = 5429963, geom = utmzen2bcalb(11, 590768, 5429963) WHERE stream_crossing_id = 396;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 590512, utm_northing = 5429851, geom = utmzen2bcalb(11, 590512, 5429851) WHERE stream_crossing_id = 397;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 588879, utm_northing = 5429103, geom = utmzen2bcalb(11, 588879, 5429103) WHERE stream_crossing_id = 398;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 585431, utm_northing = 5437174, geom = utmzen2bcalb(11, 585431, 5437174) WHERE stream_crossing_id = 401;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 586357, utm_northing = 5434690, geom = utmzen2bcalb(11, 586357, 5434690) WHERE stream_crossing_id = 403;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 586823, utm_northing = 5431063, geom = utmzen2bcalb(11, 586823, 5431063) WHERE stream_crossing_id = 407;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 581408, utm_northing = 5430613, geom = utmzen2bcalb(11, 581408, 5430613) WHERE stream_crossing_id = 410;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 583089, utm_northing = 5437866, geom = utmzen2bcalb(11, 583089, 5437866) WHERE stream_crossing_id = 411;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 583106, utm_northing = 5436620, geom = utmzen2bcalb(11, 583106, 5436620) WHERE stream_crossing_id = 412;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 583163, utm_northing = 5434827, geom = utmzen2bcalb(11, 583163, 5434827) WHERE stream_crossing_id = 413;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 580296, utm_northing = 5432983, geom = utmzen2bcalb(11, 580296, 5432983) WHERE stream_crossing_id = 422;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 573178, utm_northing = 5432704, geom = utmzen2bcalb(11, 573178, 5432704) WHERE stream_crossing_id = 427;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 571248, utm_northing = 5432974, geom = utmzen2bcalb(11, 571248, 5432974) WHERE stream_crossing_id = 430;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 569380, utm_northing = 5434984, geom = utmzen2bcalb(11, 569380, 5434984) WHERE stream_crossing_id = 431;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 484548, utm_northing = 5595000, geom = utmzen2bcalb(11, 484548, 5595000) WHERE stream_crossing_id = 432;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 484675, utm_northing = 5601547, geom = utmzen2bcalb(11, 484675, 5601547) WHERE stream_crossing_id = 433;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 484567, utm_northing = 5601771, geom = utmzen2bcalb(11, 484567, 5601771) WHERE stream_crossing_id = 434;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 483895, utm_northing = 5603261, geom = utmzen2bcalb(11, 483895, 5603261) WHERE stream_crossing_id = 436;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 487756, utm_northing = 5599290, geom = utmzen2bcalb(11, 487756, 5599290) WHERE stream_crossing_id = 438;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 501091, utm_northing = 5533036, geom = utmzen2bcalb(11, 501091, 5533036) WHERE stream_crossing_id = 439;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 493326, utm_northing = 5535940, geom = utmzen2bcalb(11, 493326, 5535940) WHERE stream_crossing_id = 446;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 529845, utm_northing = 5473215, geom = utmzen2bcalb(11, 529845, 5473215) WHERE stream_crossing_id = 450;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 530403, utm_northing = 5474345, geom = utmzen2bcalb(11, 530403, 5474345) WHERE stream_crossing_id = 452;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 531273, utm_northing = 5474994, geom = utmzen2bcalb(11, 531273, 5474994) WHERE stream_crossing_id = 453;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 530739, utm_northing = 5474775, geom = utmzen2bcalb(11, 530739, 5474775) WHERE stream_crossing_id = 455;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 527689, utm_northing = 5470339, geom = utmzen2bcalb(11, 527689, 5470339) WHERE stream_crossing_id = 456;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 510280, utm_northing = 5439294, geom = utmzen2bcalb(11, 510280, 5439294) WHERE stream_crossing_id = 469;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 510761, utm_northing = 5439332, geom = utmzen2bcalb(11, 510761, 5439332) WHERE stream_crossing_id = 470;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 510227, utm_northing = 5438467, geom = utmzen2bcalb(11, 510227, 5438467) WHERE stream_crossing_id = 471;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 509761, utm_northing = 5440020, geom = utmzen2bcalb(11, 509761, 5440020) WHERE stream_crossing_id = 472;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 504065, utm_northing = 5438668, geom = utmzen2bcalb(11, 504065, 5438668) WHERE stream_crossing_id = 474;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 501449, utm_northing = 5438000, geom = utmzen2bcalb(11, 501449, 5438000) WHERE stream_crossing_id = 475;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 507924, utm_northing = 5435112, geom = utmzen2bcalb(11, 507924, 5435112) WHERE stream_crossing_id = 476;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 506494, utm_northing = 5434836, geom = utmzen2bcalb(11, 506494, 5434836) WHERE stream_crossing_id = 477;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 507845, utm_northing = 5433959, geom = utmzen2bcalb(11, 507845, 5433959) WHERE stream_crossing_id = 478;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 507800, utm_northing = 5434099, geom = utmzen2bcalb(11, 507800, 5434099) WHERE stream_crossing_id = 479;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 501154, utm_northing = 5433744, geom = utmzen2bcalb(11, 501154, 5433744) WHERE stream_crossing_id = 487;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 500067, utm_northing = 5437814, geom = utmzen2bcalb(11, 500067, 5437814) WHERE stream_crossing_id = 488;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 497618, utm_northing = 5438045, geom = utmzen2bcalb(11, 497618, 5438045) WHERE stream_crossing_id = 489;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 495963, utm_northing = 5610563, geom = utmzen2bcalb(11, 495963, 5610563) WHERE stream_crossing_id = 492;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 490208, utm_northing = 5619765, geom = utmzen2bcalb(11, 490208, 5619765) WHERE stream_crossing_id = 494;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 483423, utm_northing = 5653337, geom = utmzen2bcalb(11, 483423, 5653337) WHERE stream_crossing_id = 495;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 482662, utm_northing = 5654230, geom = utmzen2bcalb(11, 482662, 5654230) WHERE stream_crossing_id = 496;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 482342, utm_northing = 5653991, geom = utmzen2bcalb(11, 482342, 5653991) WHERE stream_crossing_id = 497;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 485082, utm_northing = 5646432, geom = utmzen2bcalb(11, 485082, 5646432) WHERE stream_crossing_id = 498;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 486386, utm_northing = 5637582, geom = utmzen2bcalb(11, 486386, 5637582) WHERE stream_crossing_id = 500;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 472940, utm_northing = 5630196, geom = utmzen2bcalb(11, 472940, 5630196) WHERE stream_crossing_id = 501;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 472858, utm_northing = 5631216, geom = utmzen2bcalb(11, 472858, 5631216) WHERE stream_crossing_id = 502;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 473062, utm_northing = 5631214, geom = utmzen2bcalb(11, 473062, 5631214) WHERE stream_crossing_id = 503;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 475147, utm_northing = 5628997, geom = utmzen2bcalb(11, 475147, 5628997) WHERE stream_crossing_id = 506;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 477172, utm_northing = 5627735, geom = utmzen2bcalb(11, 477172, 5627735) WHERE stream_crossing_id = 507;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 477151, utm_northing = 5627511, geom = utmzen2bcalb(11, 477151, 5627511) WHERE stream_crossing_id = 508;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 478805, utm_northing = 5626826, geom = utmzen2bcalb(11, 478805, 5626826) WHERE stream_crossing_id = 509;

-- A few similar issues for Interfor 2008
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 342875, utm_northing = 5702047, geom = utmzen2bcalb(11, 342875, 5702047) WHERE stream_crossing_id = 364;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 313653, utm_northing = 5671974, geom = utmzen2bcalb(11, 313653, 5671974) WHERE stream_crossing_id = 365;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 316131, utm_northing = 5672176, geom = utmzen2bcalb(11, 316131, 5672176) WHERE stream_crossing_id = 366;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 320067, utm_northing = 5673837, geom = utmzen2bcalb(11, 320067, 5673837) WHERE stream_crossing_id = 367;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 314902, utm_northing = 5679935, geom = utmzen2bcalb(11, 314902, 5679935) WHERE stream_crossing_id = 369;

-- Lillooet 2009. Chilcotins crossings somehow ended up with completely incorrect coordinates, in the Kootenays
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 519814, utm_easting = 5621574, geom = utmzen2bcalb(10, 519814, 5621574) WHERE stream_crossing_id = 511;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 495308, utm_easting = 5642278, geom = utmzen2bcalb(10, 495308, 5642278) WHERE stream_crossing_id = 512;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 509969, utm_easting = 5624135, geom = utmzen2bcalb(10, 509969, 5624135) WHERE stream_crossing_id = 513;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 510460, utm_easting = 5625464, geom = utmzen2bcalb(10, 510460, 5625464) WHERE stream_crossing_id = 515;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 504328, utm_easting = 5619925, geom = utmzen2bcalb(10, 504328, 5619925) WHERE stream_crossing_id = 516;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 511196, utm_easting = 5660117, geom = utmzen2bcalb(10, 511196, 5660117) WHERE stream_crossing_id = 518;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 511427, utm_easting = 5659295, geom = utmzen2bcalb(10, 511427, 5659295) WHERE stream_crossing_id = 520;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 527192, utm_easting = 5643582, geom = utmzen2bcalb(10, 527192, 5643582) WHERE stream_crossing_id = 522;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 518100, utm_easting = 5662600, geom = utmzen2bcalb(10, 518100, 5662600) WHERE stream_crossing_id = 523;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 10, utm_northing = 521182, utm_easting = 5644965, geom = utmzen2bcalb(10, 521182, 5644965) WHERE stream_crossing_id = 524;

-- misc coordinate fix updates
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 465248, utm_northing = 5511477, geom = utmzen2bcalb(11, 465248, 5511477) WHERE stream_crossing_id = 102159;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_easting = 464943, utm_northing = 5510123, geom = utmzen2bcalb(11, 464943, 5510123) WHERE stream_crossing_id = 102160;

-- skeena, glacier cr & camp cr (camp cr seems to not be official bcgnis)
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 9, utm_easting = 518345, utm_northing = 6057309, geom = utmzen2bcalb(9, 518345, 6057309) WHERE stream_crossing_id = 123328;
UPDATE pscis.pscis_stream_cross_loc_point SET utm_zone = 9, utm_easting = 518008, utm_northing = 6058234, geom = utmzen2bcalb(9, 518008, 6058234) WHERE stream_crossing_id = 123329;


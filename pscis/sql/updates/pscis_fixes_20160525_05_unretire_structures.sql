UPDATE pscis.pscis_structures
SET who_updated = 'DATAFIX_20160525',

    retirement_date = NULL
WHERE structure_id IN
(8754,8856,8738,8841,8791,8814,8850,8848,8793,8852,
 8860,8838,8737,8772,8796,8799,8792,8751,8818,8812,
 8858,8755,8864,8820,8797,8816,8735,8810,8853,8753,
 8731,8768,8770,8847,8750,8827,8842,8837,8832,8798,
 8851,8854,8859,8840,8741,8855,8839,8809,8779,8771,
 8817,8803,8790,8736,8762,8811,8849,8857,8862,8739,
 8863,8730,8821,8752,8846,8761,8819);
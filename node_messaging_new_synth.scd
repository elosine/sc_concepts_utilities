s.sendMsg( \s_new, synthName, nodeID, addAction, targetGroup(1 will add to default group), agrument/value pairs (separated by comma) )

// add actions:
// 0	add the new node to the the head of the group specified by the add target ID.
// 1	add the new node to the the tail of the group specified by the add target ID.
// 2	add the new node just before the node specified by the add target ID.
// 3	add the new node just after the node specified by the add target ID.
// 4	the new node replaces the node specified by the add target ID. The target node is freed.

SynthDef(\fff, {|freq amp|}).add;
s.sendMsg(\s_new, \fff, 7891, 0, 1, \freq, 440, \amp, 0.5);
s.queryAllNodes;


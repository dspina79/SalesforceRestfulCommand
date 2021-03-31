Map<String, Object> execute1 = RESTCommandCenter.execute('dailyAcctUpdate');
Map<String, Object> execute2 = RESTCommandCenter.execute('clearInactives');
Map<String, Object> execute3 = RESTCommandCenter.execute('openOpps');

List<Map<String, Object>> items = new List<Map<String, Object>> {execute1, execute2, execute3};

for (Map<String, Object> item : items) {
    System.debug(item.get('StatusCode'));
    System.debug(item.get('Body'));
}

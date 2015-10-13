app = Application('omnifocus');
app.includeStandardAdditions = true;
var current = Application.currentApplication();
current.includeStandardAdditions = true;
var doc = app.defaultDocument;

function getProjectStatusById(pid) {
  var projects = doc.flattenedProjects.whose({id: pid});
  return projects.status()[0];
}
function getProjectNameById(pid) {
  var projects = doc.flattenedProjects.whose({id: pid});
  return projects.name();
}

function projectIdList() {
  if(typeof(__projectIdList) == "undefined"){
    __projectIdList = doc.flattenedProjects.whose({completed: false})().map(function(e){ return e.id() })
  }
  return __projectIdList
}

function contextIdList() {
  if(typeof(__contextIdList) == "undefined"){
    __contextIdList = doc.flattenedContexts().map(function(e){ return e.id() })
  }
  return __contextIdList
}

function contextIdList() {
  if(typeof(__contextIdList) == "undefined"){
    __contextIdList = doc.flattenedContexts().map(function(e){ return e.id() })
  }
  return __contextIdList
}

function taskIdList() {
  if(typeof(__taskIdList) == "undefined"){
    __taskIdList = doc.flattenedTasks.whose({completed: false})().map(function(e){ return e.id() })
  }
  return __taskIdList
}

function getObjType(obj){
  if(projectIdList().indexOf(obj.id()) >= 0){
    return('Project')
  }else if(contextIdList().indexOf(obj.id()) >= 0){
    return('Context')
  }else if(taskIdList().indexOf(obj.id()) >= 0){
    return('Task')
  }else if(obj.id() == app.defaultDocument().id()){
    return('Document')
  }else{
    return('unknown!!!')
  }
}

function isStatusActive(obj) {
  return objStatus(obj) == 'active'
}

function objStatus(obj) {
  if(getObjType(obj) == 'Project'){
    return obj.containingProject().status()
  }else if(getObjType(obj) == 'Task'){
    return objStatus(obj.container())
  }else if(getObjType(obj) == 'Document'){
    return 'active'
  }else{
    return obj
  }
}

tasks = doc.flattenedTasks.whose({completed: false})();
names = [];
tasks.forEach(function(e){
  var ctx = (e.context() ? e.context.name() : null);
  var prj = getProjectNameById(e.container().id());
  var prjStatus = getProjectStatusById(e.container().id());
  var obj = {
    id: e.id(),
    name: e.name(),
	project: prj,
	status: isStatusActive(e),
    context: ctx,
    deferDate: e.deferDate(),
    dueDate: e.dueDate(),
    note: e.note(),
  }
  names.push(obj)
})
JSON.stringify(names)

// Read-only Figma native Plugin API / Scripter audit. Does not fetch or write data.
const source = await figma.getNodeByIdAsync('0:1');
if (!source || source.type !== 'PAGE') throw new Error('Original page not found');
await figma.setCurrentPageAsync(source);
const frames = source.children.filter(n => n.type === 'FRAME');
const result = frames.map(f => ({
  id: f.id, name: f.name, width: f.width, height: f.height,
  layoutMode: f.layoutMode, fixedChildren: f.numberOfFixedChildren,
  directChildren: f.children.map(n => ({
    id: n.id, name: n.name, type: n.type, x: n.x, y: n.y,
    width: n.width, height: n.height,
    layoutMode: 'layoutMode' in n ? n.layoutMode : null
  })),
  actions: f.findAll(n => n.type === 'TEXT' &&
    /S\d\d|Bắt đầu|Đăng nhập|Tạo tài khoản|Tiếp theo|Nhận góp ý|Lưu|Dừng|Kiểm tra|Quy chuẩn|Đặc tả|Specs|Annotation/.test(n.characters)
  ).map(t => ({id:t.id,text:t.characters,parentId:t.parent.id,parentName:t.parent.name,
    ancestor:t.parent.parent ? {id:t.parent.parent.id,name:t.parent.parent.name} : null})),
  existingConnections: f.findAll(n => 'reactions' in n && n.reactions.length > 0)
    .map(n => ({id:n.id,name:n.name,reactions:n.reactions}))
}));
print(JSON.stringify({pageId:source.id,frameCount:frames.length,frames:result},null,2));

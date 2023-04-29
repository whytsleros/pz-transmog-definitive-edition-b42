"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var path = require('path');
var uuid_1 = require("uuid");
var fs_1 = require("fs");
var tmogItems = new Array(1000).fill(1).map(function (u, i) {
    var guid = (0, uuid_1.v4)();
    return {
        guid: guid,
        clothingItemPath: "media/clothing/clothingItems/TransmogItem_".concat(i, ".xml"),
        clothingItemXml: "\n    <?xml version=\"1.0\" encoding=\"utf-8\"?>\n      <clothingItem>\n        <m_MaleModel></m_MaleModel>\n        <m_FemaleModel></m_FemaleModel>\n        <m_GUID>".concat(guid, "</m_GUID>\n        <m_Static>false</m_Static>\n        <m_AllowRandomHue>false</m_AllowRandomHue>\n        <m_AllowRandomTint>false</m_AllowRandomTint>\n        <m_AttachBone></m_AttachBone>\n        <m_BaseTextures>emptytexture</m_BaseTextures>\n      </clothingItem>\n    ").trim(),
        scriptItemName: "TransmogItem_".concat(i),
        scriptItem: "\n    item TransmogItem_".concat(i, "\n    {\n      DisplayCategory = Accessory,\n      Weight\t=\t0,\n      Type\t=\tClothing,\n      DisplayName\t=\tTransmogItem_").concat(i, ",\n      Icon\t=\tBelt,\n      BodyLocation = Belt,\n      ClothingItem = TransmogItem_").concat(i, ",\n      WorldStaticModel = TShirt_Ground,\n    }").trim()
    };
});
for (var i = 0; i < tmogItems.length; i++) {
    var tmogItem = tmogItems[i];
    (0, fs_1.writeFileSync)(path.join(__dirname, "./Contents/mods/TransmogRebuild", tmogItem.clothingItemPath), tmogItem.clothingItemXml, 'utf8');
}
var fileGuidTable = "\n<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<fileGuidTable>\n  <files>\n  ".concat(tmogItems.map(function (_a, i) {
    var guid = _a.guid;
    return ("\n  <path>media/clothing/clothingItems/TransmogItem_".concat(i, ".xml</path>\n  <guid>").concat(guid, "</guid>"));
}).join('\n'), "\n  </files>\n</fileGuidTable>\n").trim();
(0, fs_1.writeFileSync)(path.join(__dirname, "Contents/mods/TransmogRebuild/media/fileGuidTable.xml"), fileGuidTable, 'utf8');
var scriptItem = "\nmodule TransmogRebuild {\n\timports { Base }\n\n  ".concat(tmogItems.map(function (_a) {
    var scriptItem = _a.scriptItem;
    return scriptItem;
}).join('\n\n\t'), "\n\n}").trim();
(0, fs_1.writeFileSync)(path.join(__dirname, "Contents/mods/TransmogRebuild/media/scripts/TransmogItems.txt"), scriptItem, 'utf8');

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var uuid_1 = require("uuid");
var fs_1 = require("fs");
var path = require('path');
var generateClothingItemXml = function (guid) {
    return "\n<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<clothingItem>\n  <m_MaleModel></m_MaleModel>\n  <m_FemaleModel></m_FemaleModel>\n  <m_GUID>".concat(guid, "</m_GUID>\n  <m_Static>false</m_Static>\n  <m_AllowRandomHue>false</m_AllowRandomHue>\n  <m_AllowRandomTint>false</m_AllowRandomTint>\n  <m_AttachBone></m_AttachBone>\n  <m_BaseTextures>emptytexture</m_BaseTextures>\n</clothingItem>\n");
};
var itemIds = new Array(1000).fill(1).map(function (u) { return (0, uuid_1.v4)(); });
var fileGuidTableFiles = [];
for (var i = 0; i < itemIds.length; i++) {
    var guid = itemIds[i];
    var clothingItemXml = generateClothingItemXml(guid);
    var clothingItemXmlPath = path.join(__dirname, "./Contents/mods/TransmogRebuild/media/clothing/clothingItems/TransmogItem_".concat(i, ".xml"));
    (0, fs_1.writeFileSync)(clothingItemXmlPath, clothingItemXml, 'utf8');
    fileGuidTableFiles.push("\n  <path>media/clothing/clothingItems/TransmogItem_".concat(i, ".xml</path>\n  <guid>").concat(guid, "</guid>"));
    console.log('Generated Item #', i);
}
var fileGuidTableHead = "\n<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<fileGuidTable>\n\t<files>\n";
var fileGuidTableFoot = "\n  </files>\n</fileGuidTable>\n";
var fileGuidTable = (fileGuidTableHead + fileGuidTableFiles.join('\n') + fileGuidTableFoot).trim();
var fileGuidTableXmlPath = path.join(__dirname, "Contents/mods/TransmogRebuild/media/fileGuidTable.xml");
(0, fs_1.writeFileSync)(fileGuidTableXmlPath, fileGuidTable, 'utf8');

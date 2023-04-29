import { v4 as uuidv4 } from 'uuid';

import { writeFileSync } from 'fs';
const path = require('path');

const generateClothingItemXml = (guid) =>
  `
<?xml version="1.0" encoding="utf-8"?>
<clothingItem>
  <m_MaleModel></m_MaleModel>
  <m_FemaleModel></m_FemaleModel>
  <m_GUID>${guid}</m_GUID>
  <m_Static>false</m_Static>
  <m_AllowRandomHue>false</m_AllowRandomHue>
  <m_AllowRandomTint>false</m_AllowRandomTint>
  <m_AttachBone></m_AttachBone>
  <m_BaseTextures>emptytexture</m_BaseTextures>
</clothingItem>
`

const itemIds = new Array(1000).fill(1).map(u => uuidv4());
const fileGuidTableFiles: string[] = [];

for (let i = 0; i < itemIds.length; i++) {
  
  const guid = itemIds[i];
  const clothingItemXml = generateClothingItemXml(guid);
  const clothingItemXmlPath = path.join(__dirname, `./Contents/mods/TransmogRebuild/media/clothing/clothingItems/TransmogItem_${i}.xml`);

  writeFileSync(clothingItemXmlPath, clothingItemXml, 'utf8');

  fileGuidTableFiles.push(`
  <path>media/clothing/clothingItems/TransmogItem_${i}.xml</path>
  <guid>${guid}</guid>`)

  console.log('Generated Item #', i);
}

const fileGuidTableHead = `
<?xml version="1.0" encoding="utf-8"?>
<fileGuidTable>
	<files>
`;

const fileGuidTableFoot = `
  </files>
</fileGuidTable>
`;

const fileGuidTable = (fileGuidTableHead + fileGuidTableFiles.join('\n') + fileGuidTableFoot).trim()

const fileGuidTableXmlPath = path.join(__dirname, `Contents/mods/TransmogRebuild/media/fileGuidTable.xml`);

writeFileSync(fileGuidTableXmlPath, fileGuidTable, 'utf8');
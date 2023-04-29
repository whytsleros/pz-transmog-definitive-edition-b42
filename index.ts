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

var itemIds = new Array(1000).fill(1).map(u => uuidv4());

for (let i = 0; i < itemIds.length; i++) {
  
  const guid = itemIds[i];
  
  const clothingItemXml = generateClothingItemXml(guid)
  
  writeFileSync(path.join(__dirname, './Contents/mods/TransmogRebuild/media/clothing/clothingItems/InvisibleItem.xml'), clothingItemXml, 'utf8');

  console.log('Generated Item #', i)
}


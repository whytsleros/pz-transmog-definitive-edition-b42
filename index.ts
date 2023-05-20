const path = require('path');
import { v4 as uuidv4 } from 'uuid';
import { writeFileSync } from 'fs';

const tmogItems = new Array(5000).fill(1).map((u, i) => {
  const guid = uuidv4()
  return {
    guid,
    clothingItemPath: `media/clothing/clothingItems/TransmogItem_${i}.xml`,
    clothingItemXml: `
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
    `.trim(),
    scriptItemName: `TransmogItem_${i}`,
    scriptItem: `
    item TransmogItem_${i}
    {
      Type = Clothing,
      DisplayCategory = Transmog,
      Weight = 0,
      Cosmetic = TRUE,
      DisplayName = TransmogItem_${i},
      Icon = TransmogItem,
      BodyLocation = TransmogLocation,
      ClothingItem = TransmogItem_${i},
    }`.trim()
  } as const;
});

for (let i = 0; i < tmogItems.length; i++) {
  const tmogItem = tmogItems[i];

  writeFileSync(path.join(__dirname, `./Contents/mods/TransmogDE`, tmogItem.clothingItemPath), tmogItem.clothingItemXml, 'utf8');
}

const files = tmogItems.map(({ guid }, i) => (`
  <files>
    <path>media/clothing/clothingItems/TransmogItem_${i}.xml</path>
    <guid>${guid}</guid>
  </files>`
)).join('\n')

const fileGuidTable = `
<?xml version="1.0" encoding="utf-8"?>
<fileGuidTable>
${files}
</fileGuidTable>
`.trim();


writeFileSync(path.join(__dirname, `Contents/mods/TransmogDE/media/fileGuidTable.xml`), fileGuidTable, 'utf8');

const scriptItem = `
module TransmogDE {
 imports { Base }

  ${tmogItems.map(({scriptItem}) => scriptItem).join('\n\n\t')}

}`.trim()

writeFileSync(path.join(__dirname, `Contents/mods/TransmogDE/media/scripts/TransmogItems.txt`), scriptItem, 'utf8');
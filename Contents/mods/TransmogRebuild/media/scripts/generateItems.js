const fs = require('fs')

const header =
  `module TransmogV3 {
	imports	{
		Base
	}
`

const footer = `}`

const templateCosmetic = (idx) =>
  `  item TransmogCosmetic_${idx} {
    DisplayCategory = Transmog,
    Type = Clothing,
    Cosmetic = TRUE,
    DisplayName = TransmogCosmetic_${idx},
    ClothingItem = InvisibleItem,
    BodyLocation = Transmog_Location_${idx},
    Icon = NoseRing_Gold,
    Weight = 0,
  }
`

// i + 1, lua counts from 1
const templatesCosmetic = Array.from({ length: 5000 }, (_, i) => templateCosmetic(i + 1));
const textCosmetic = header + templatesCosmetic.join('') + footer
fs.writeFile('./TransmogCosmetic.txt', textCosmetic, err => {
  if (err) {
    console.error(err)
    return
  }
})

console.log("Done")
// (Copyright (c) 2023 v1ld.git@gmail.com
//
// Feel free to reuse under the MIT License.

@replaceMethod(RPGManager)
public final static func GetRetrievableAttachments(itemData: wref<gameItemData>) -> array<ItemAttachments> {
  let i: Int32;
  let innerPart: InnerItemData;
  let innerPartID: ItemID;
  let partTags: array<CName>;
  let restoredAttachments: array<ItemAttachments>;
  let slotsToCheck: array<TweakDBID>;
  let tempArr: array<TweakDBID>;
  if !IsDefined(itemData) {
    return restoredAttachments;
  };
  if Equals(RPGManager.GetItemCategory(itemData.GetID()), gamedataItemCategory.Weapon) {
    slotsToCheck = RPGManager.GetAttachmentSlotIDs();
    tempArr = RPGManager.GetModsSlotIDs(itemData.GetItemType());
    i = 0;
    while i < ArraySize(tempArr) {
      ArrayPush(slotsToCheck, tempArr[i]);
      i += 1;
    };
    i = 0;
    while i < ArraySize(slotsToCheck) {
      itemData.GetItemPart(innerPart, slotsToCheck[i]);
      innerPartID = InnerItemData.GetItemID(innerPart);
      // v1ld: skip check on parts tag of whether item is Retrievable
      // partTags = InnerItemData.GetStaticData(innerPart).Tags();
      if ItemID.IsValid(innerPartID) { // was: && ArrayContains(partTags, n"Retrievable") {
        ArrayPush(restoredAttachments, ItemAttachments.Create(innerPartID, slotsToCheck[i]));
      };
      i += 1;
    };
  };
  return restoredAttachments;
}
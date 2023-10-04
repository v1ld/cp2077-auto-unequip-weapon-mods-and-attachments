// (Copyright (c) 2023 v1ld.git@gmail.com
//
// Feel free to reuse under the MIT License.
//
// All changed areas have a comment with vild: in it.

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

@replaceMethod(CraftingSystem)
private final const func DisassembleItem(target: wref<GameObject>, itemID: ItemID, amount: Int32) -> Void {
  let restoredAttachments: array<ItemAttachments>;
  let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
  let listOfIngredients: array<IngredientData> = this.GetDisassemblyResultItems(target, itemID, amount, restoredAttachments);
  let i: Int32 = 0;
  // v1ld: this was not restoring attachments, just removing them.
  // The equivalent code for selling does restore, so this might have been an oversight.
  let removedID: ItemID;
  while i < ArraySize(restoredAttachments) {
    removedID = transactionSystem.RemovePart(this.m_playerCraftBook.GetOwner(), itemID, restoredAttachments[i].attachmentSlotID);
    if ItemID.IsValid(removedID) {
      transactionSystem.GiveItem(this.m_playerCraftBook.GetOwner(), restoredAttachments[i].itemID, 1);
    };
    i += 1;
  };
  GameInstance.GetTelemetrySystem(this.GetGameInstance()).LogItemDisassembled(target, itemID);
  transactionSystem.RemoveItem(target, itemID, amount);
  i = 0;
  while i < ArraySize(listOfIngredients) {
    transactionSystem.GiveItem(target, ItemID.FromTDBID(listOfIngredients[i].id.GetID()), listOfIngredients[i].quantity);
    i += 1;
  };
  this.UpdateBlackboard(CraftingCommands.DisassemblingFinished, itemID, listOfIngredients);
}

@replaceMethod(CraftingSystem)
private final const func ProcessDisassemblingPerks(amount: Int32, out disassembleResult: array<IngredientData>, itemData: wref<gameItemData>, restoredAttachments: script_ref<array<ItemAttachments>>, opt calledFromUI: Bool) -> Void {
  let i: Int32;
  let innerPart: InnerItemData;
  let innerPartID: ItemID;
  let itemCategory: gamedataItemCategory;
  let matQuality: gamedataQuality;
  let partTags: array<CName>;
  let slotsToCheck: array<TweakDBID>;
  let succNum: Int32;
  let tempArr: array<TweakDBID>;
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
  let tempStat: Float = statsSystem.GetStatValue(Cast<StatsObjectID>(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.DisassemblingIngredientsDoubleBonus);
  if tempStat > 0.00 {
    i = 0;
    while i < ArraySize(disassembleResult) {
      disassembleResult[i].quantity = Cast<Int32>(Cast<Float>(disassembleResult[i].quantity) * 1.50);
      i += 1;
    };
  };
  if !calledFromUI {
    tempStat = statsSystem.GetStatValue(Cast<StatsObjectID>(this.m_playerCraftBook.GetOwner().GetEntityID()), gamedataStatType.DisassemblingMaterialQualityObtainChance);
    matQuality = RPGManager.GetItemDataQuality(itemData);
    if NotEquals(matQuality, gamedataQuality.Invalid) {
      succNum = this.GetSuccessNum(tempStat, amount);
      if succNum > 0 {
        this.CreateIngredientDataOfQuality(succNum, matQuality, disassembleResult);
      };
      if matQuality <= gamedataQuality.Epic {
        matQuality = RPGManager.GetBumpedQuality(matQuality);
        succNum = this.GetSuccessNum(tempStat / 4.00, amount);
        if succNum > 0 {
          this.CreateIngredientDataOfQuality(succNum, matQuality, disassembleResult);
        };
      };
    };
  };
  itemCategory = RPGManager.GetItemCategory(itemData.GetID());
  if Equals(itemCategory, gamedataItemCategory.Weapon) {
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
        ArrayPush(Deref(restoredAttachments), ItemAttachments.Create(innerPartID, slotsToCheck[i]));
      };
      i += 1;
    };
  };
}

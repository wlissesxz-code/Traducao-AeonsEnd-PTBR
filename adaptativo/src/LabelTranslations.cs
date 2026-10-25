using System;
using System.Collections.Generic;
public static partial class PortugueseSupport {
    static readonly Dictionary<string,string> labels = new Dictionary<string,string>(StringComparer.OrdinalIgnoreCase) {
        {"Gem", "Gema"},
        {"Relic", "Relíquia"},
        {"Spell", "Feitiço"},
        {"Attack", "Ataque"},
        {"Minion", "Lacaio"},
        {"Power", "Poder"},
        {"OR", "OU"},
        {"Persistent", "Persistente"},
        {"Adelheim, Breach Mage Weaponsmith", "Adelheim, mago de fendas e armeiro"},
        {"Brama, Breach Mage Elder", "Brama, anciã dos magos de fendas"},
        {"Garu, Oathsworn Protector", "Garu, protetor juramentado"},
        {"Ghan, Gem Scavenger", "Ghan, catador de gemas"},
        {"Kadir, Breach Mage Delver", "Kadir, exploradora e maga de fendas"},
        {"Lash, Breach Mage Scout", "Lash, batedor e mago de fendas"},
        {"Last words of Quilion Rafe, Far Hollow watchman", "Últimas palavras de Quilion Rafe, vigia de Far Hollow"},
        {"Lexive, Arcane Theorist", "Lexive, teórico arcano"},
        {"Malastar, Breach Mage Mentor", "Malastar, mentor dos magos de fendas"},
        {"Mazahaedron, Henge Mystic", "Mazahaedron, místico do círculo de pedras"},
        {"Mist, Breach Mage Dagger Captain", "Mist, capitã das adagas e maga de fendas"},
        {"Mist, Dagger Captain", "Mist, capitã das adagas"},
        {"Nerva, survivor", "Nerva, sobrevivente"},
        {"Nym, Breach Apprentice", "Nym, aprendiz de mago de fendas"},
        {"Ohat, Dirt Merchant", "Ohat, mercador de terra"},
        {"Phaedraxa, Breach Mage Seer", "Phaedraxa, vidente e maga de fendas"},
        {"Reeve, Breach Mage Elite", "Reeve, mago de fendas de elite"},
        {"Xae, Guild Mage Pilgrim", "Xae, mago peregrino da Guilda"},
        {"Xaxos, Breach Mage Adept", "Xaxos, adepto dos magos de fendas"},
        {"Xaxos, Voidbringer", "Xaxos, portador do Vazio"},
        {"Z'hana, Breach Mage Renegade", "Z'hana, maga de fendas renegada"}
    };
    public static string TranslateLabel(string value) {
        if (String.IsNullOrEmpty(value)) return value;
        value = TranslateKnown(value);
        string result;
        if (!labels.TryGetValue(value.Trim(), out result)) return value;
        return value.Trim() == value.Trim().ToUpperInvariant() ? result.ToUpperInvariant() : result;
    }
}

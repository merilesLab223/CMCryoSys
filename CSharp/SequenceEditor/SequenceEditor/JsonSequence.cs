using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace SequenceEditor
{
    /// <summary>
    /// Implements sequence data.
    /// </summary>
    [JsonObject(MemberSerialization.OptIn)]
    public class JsonSequence
    {
        public JsonSequence()
        {
        }

        #region Serialzed members

        /// <summary>
        /// A liste of internal sequences.
        /// </summary>
        [JsonProperty]
        public List<JsonSequence> InternalSequences { get; private set; } = new List<JsonSequence>();

        /// <summary>
        /// The name of the sequence (or lable).
        /// </summary>
        [JsonProperty]
        public string Name { get; set; }

        /// <summary>
        /// If true then the sequences can have internal sequences.
        /// </summary>
        [JsonProperty]
        public bool CanHaveInternalSequences { get; private set; }

        /// <summary>
        /// The code for the sequence element.
        /// </summary>
        [JsonProperty]
        public string Code { get; set; }

        /// <summary>
        /// The code for the sequence start
        /// </summary>
        [JsonProperty]
        public string SequenceEndCode { get; set; }

        /// <summary>
        /// The code for the sequence start.
        /// </summary>
        [JsonProperty]
        public string SequenceStartCode { get; set; }

        #endregion
    }
}

<template>
  <q-card
    @mouseenter="isHovered = true"
    @mouseleave="isHovered = false"
    :flat="isHovered"
    :bordered="isHovered"
    class="cursor-pointer"
  >
    <img :src="imgSource" style="width: 100%">
    <q-card-section v-if="imgDesc" class="q-mt-sm">
      <div>
        {{imgDesc}}
      </div>
    </q-card-section>
  </q-card>
</template>

<script>
export default {
  name: "ImageCardDisplay",
  props: {
    // imgSource: {
    //   type: String,
    //   required: true
    // },
    baseURI: {
      type: Object,
      required: true
    },
    tokenId: {
      type: [String, Number]
    }
  },
  data() {
    return {
      imgSource: '',
      imgDesc: '',
      isHovered: false
    }
  },
  async mounted() {
    // get metadata should have image, description
    const metaData = await this.$api.get(`${this.baseURI}${this.tokenId}`)
    console.log('metadata is', this.tokenId, metaData)
    this.imgSource = metaData.data['image']
    this.imgDesc = metaData.data['description']

  }
}
</script>

<style scoped>

</style>

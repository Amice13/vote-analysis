<template>
  <v-layout row wrap justify-center align-center>
    <v-flex xs12 v-if="current === 'main'">
      <v-card>
        <v-card-title><div><div class="display-2 mb-1" style="font-weight: bold;">Загальний результат</div><div>Загальна кількість виборців: {{ data.length }}.</div></div></v-card-title>
        <v-card-text>
          <v-layout row wrap pb-3>
            <v-flex xs12 sm6 md7 id="search-place">
              <v-text-field name="search" v-model="filter" @keyup.enter="filterList" solo hide-details prepend-icon="search" label="Фільтр" id="search"></v-text-field>
            </v-flex>
            <v-flex xs12 sm5 md4 offset-sm1 text-xs-right>
              <v-select v-model="sort" class="sort" @input="setSort" v-bind:class="[sortType]" :items="sortOptions" item-text="name" item-value="id" prepend-icon="sort" label="Сортування" solo></v-select>
            </v-flex>
          </v-layout>
          <v-layout row wrap pb-3>
            <v-flex xs12 v-for="(item, index) in candidatesCount" :key="'rating' + index" v-show="candidateFiltered(item.candidate)">
              <v-card class="mb-3">
                <v-layout row wrap fill-height align-center>
                  <v-flex xs1 sm1 md1 class="text-xs-center" style="min-width:120px;">
                    <div style="padding:5px;">
                      <h1 style="font-weight:bold; font-size:2.5em;">{{ item.rating }}</h1>
                      <div style="font-size: 12px;"><v-icon color="black" size="16">person</v-icon> {{ item.counts }} голосів</div>
                    </div>
                  </v-flex>
                  <v-flex xs1 sm2 md2 lg1 text-xs-center class="hidden-xs-only">
                    <v-img class="user-image" style="background:#666;" :src="candidateImage(item.id)" contains aspect-ratio="0.6">
                      <div v-bind:class="success(item.rating)"><v-icon color="white">{{ success(item.rating) }}</v-icon></div>
                    </v-img>
                  </v-flex>
                  <v-flex xs6 sm7 md8>
                    <div class="pl-4">
                      <h3 class="headline mt-3 mb-1" style="font-weight:bold;">{{ item.candidate }}</h3>
                      <span v-if="candidateProp(item.id, 'ngo_name')" style="background: #EEE; padding: 2px 4px;">{{ candidateProp(item.id, 'ngo_name') }}</span>
                      <div class="links mt-4">
                        <a v-if="candidateProp(item.id, 'social')" :href="candidateProp(item.id, 'social')" target="_blank">
                          <v-icon color="blue" size="16">share</v-icon> Профіль у Facebook</a>
                        <span v-if="candidateProp(item.id, 'social')" class="divider hidden-sm-and-down">|</span>
                        <br v-if="candidateProp(item.id, 'social')" class="hidden-md-and-up"/>
                        <a v-if="candidateProp(item.id, 'ngo_web')" :href="candidateProp(item.id, 'ngo_web')" target="_blank">
                          <v-icon color="blue" size="16">public</v-icon> Сайт організації</a>
                        <span v-if="candidateProp(item.id, 'ngo_web') && candidateProp(item.id, 'ngo_social')" class="divider hidden-sm-and-down">|</span>
                        <br v-if="candidateProp(item.id, 'ngo_web') && candidateProp(item.id, 'ngo_social')" class="hidden-md-and-up"/>
                        <a v-if="candidateProp(item.id, 'ngo_social')" :href="candidateProp(item.id, 'ngo_social')" target="_blank">
                          <v-icon color="blue" size="16">domain</v-icon> Організація у Facebook</a>
                      </div>
                    </div>
                  </v-flex>
                </v-layout>
              </v-card>
            </v-flex>
          </v-layout>
        </v-card-text>
      </v-card>
    </v-flex>

    <v-flex xs12 v-if="current === 'time'">
      <v-card>
        <v-card-title><div class="mr-5"><div class="display-2 mb-1" style="font-weight: bold;">Аналіз процедури голосування</div><div>Загальна кількість виборців: {{ data.length }}. Відображено - {{ filteredData.length }}.</div></div>
        <v-select class="sort" v-model="typeOfTime" :items="typesOfTime" item-text="name" item-value="id" prepend-icon="av_timer" label="Одиниця аналізу" solo></v-select>

        </v-card-title>
        <v-card-text>
          <v-layout row wrap>
          <!-- Timeline -->
          <v-flex xs12>
            <v-card class="elevation-4 mb-4">
              <v-card-title primary-title>
                <v-avatar size="36px"><v-icon>access_time</v-icon>
                </v-avatar>
                <h2>Кількість голосів за часом</h2>
              </v-card-title>
              <v-card-text>
                <chartist ratio="ct-double-octave" type="Line" :data="timeLineChart" :options="timeLineOptions"></chartist>          
                  <v-layout row align-center>
                    <v-flex shrink text-xs-center style="width: 60px">
                      <span>{{ formatDate(timeRange[0]) }}</span>
                    </v-flex>
                    <v-flex class="px-3">
                      <v-range-slider validate-on-blur v-model="timeRange" v-on:mouseup="setTimeRangeFilter" :max="maxDate" :min="minDate" :step="timeStep"></v-range-slider>
                    </v-flex>
                    <v-flex shrink style="width: 60px">
                      <span>{{ formatDate(timeRange[1]) }}</span>
                    </v-flex>
                  </v-layout>
              </v-card-text>
            </v-card>
          </v-flex>

          <v-layout row wrap  class="elevation-4 mb-4">
            
            <!-- Candidates -->
            <v-flex xs12 md4>
              <v-card flat>
                <v-card-title primary-title>
                  <v-avatar size="36px"><v-icon>person</v-icon>
                  </v-avatar>
                  <h2>Кандидати</h2>
                </v-card-title>
                <v-card-text>
                  <chartist ratio="ct-major-second" type="Bar" :data="top15CandidatesChart" :options="chartOptions('horizontalBar')"></chartist>          
                  <v-layout row>
                    <v-flex xs12>
                      <v-autocomplete v-model="filters.candidates" :items="filteredCandidatesCount" box chips color="blue-grey lighten-2"
                        label="Фільтр кандидатів" item-text="candidate" item-value="id" multiple>
                        <template v-slot:selection="data">
                          <v-chip :selected="data.selected" close class="chip--select-multi" @input="remove(data.item.id, 'candidates')">
                            <v-avatar><img :src="candidateImage(data.item.id)"></v-avatar> {{ candidateProp(data.item.id, 'idName') }}
                          </v-chip>
                        </template>
                        <template v-slot:item="data">
                          <template v-if="typeof data.item !== 'object'">
                            <v-list-tile-content v-text="data.item"></v-list-tile-content>
                          </template>
                          <template v-else>
                            <v-list-tile-avatar>
                              <img :src="candidateImage(data.item.id)">
                            </v-list-tile-avatar>
                            <v-list-tile-content>
                              <v-list-tile-title>{{ data.item.candidate }} ({{ data.item.counts }} голосів)</v-list-tile-title>
                              <v-list-tile-sub-title v-html="candidateProp(data.item.id, 'ngo_name')"></v-list-tile-sub-title>
                            </v-list-tile-content>
                          </template>
                        </template>
                      </v-autocomplete>
                    </v-flex>
                  </v-layout>
                </v-card-text>
              </v-card>
            </v-flex>

            <!-- Mobile Operators -->
            <v-flex xs12 md4>
              <v-card flat>
                <v-card-title primary-title>
                  <v-avatar size="36px"><v-icon>smartphone</v-icon>
                  </v-avatar>
                  <h2>Мобільні оператори</h2>
                </v-card-title>
                <v-card-text>
                  <chartist ratio="ct-major-second" type="Bar" :data="mobileCountsChart" :options="Object.assign(chartOptions('horizontalBar'), { axisY: { offset: 60 } })"></chartist>          
                  <v-layout row>
                    <v-flex xs12>
                      <v-autocomplete v-model="filters.mobile" :items="mobileFilter" box chips color="blue-grey lighten-2"
                        label="Фільтр операторів" item-text="mobile" item-value="mobile" multiple>
                        <template v-slot:selection="data">
                          <v-chip :selected="data.selected" close class="chip--select-multi" @input="remove(data.item.mobile, 'mobile')">
                            <v-avatar><img :src="mobileProp(data.item.mobile, 'photo')"></v-avatar> {{ data.item.mobile }}
                          </v-chip>
                        </template>
                        <template v-slot:item="data">
                          <template v-if="typeof data.item !== 'object'">
                            <v-list-tile-content v-text="data.item"></v-list-tile-content>
                          </template>
                          <template v-else>
                            <v-list-tile-avatar>
                              <img :src="mobileProp(data.item.mobile, 'photo')">
                            </v-list-tile-avatar>
                            <v-list-tile-content>
                              <v-list-tile-title>{{ data.item.mobile }} ({{ data.item.counts }} голосів)</v-list-tile-title>
                            </v-list-tile-content>
                          </template>
                        </template>
                      </v-autocomplete>
                    </v-flex>
                  </v-layout>
                </v-card-text>
              </v-card>
            </v-flex>

            <!-- Counts hist -->
            <v-flex xs12 md4>
              <v-card flat>
                <v-card-title primary-title>
                  <v-avatar size="36px"><v-icon>insert_chart</v-icon>
                  </v-avatar>
                  <h2>Кількість голосів</h2>
                </v-card-title>
                <v-card-text>
                  <chartist ratio="ct-major-second" type="Bar" :data="choiceCountsChart"></chartist>          
                  <v-layout row align-center>
                    <v-flex shrink text-xs-center style="width: 60px">
                      <span>{{ choiceRange[0] }}</span>
                    </v-flex>
                    <v-flex class="px-3">
                      <v-range-slider validate-on-blur v-model="choiceRange" v-on:mouseup="setChoiceRangeFilter" :max="maxChoice" :min="1" :step="1"></v-range-slider>
                    </v-flex>
                    <v-flex shrink style="width: 60px">
                      <span>{{ choiceRange[1] }}</span>
                    </v-flex>
                  </v-layout>
                </v-card-text>
              </v-card>
            </v-flex>
          </v-layout>

          <!-- Timeline -->
          <v-flex xs12>
            <v-card class="elevation-4 mb-4">
              <v-card-title primary-title>
                <v-avatar size="36px"><v-icon>timeline</v-icon>
                </v-avatar>
                <h2>Таймлайн кандидатів</h2>
                <v-spacer></v-spacer>
                <v-btn @click="getCandidatesTimeLineChart" color="primary">Розрахувати</v-btn>
              </v-card-title>
              <v-card-text v-if="timelines.length">
                <v-layout row wrap>
                  <v-flex xs12 sm6 md4 v-for="(timeline, index) in timelines" :key="'candidateTimeline' + index">
                    <v-card class="mb-1 ml-1 mr-1 mt-1">
                      <v-card-title primary-title>
                        <h4 class="subheading">
                          <v-avatar size="36" color="primary" class="mr-2">
                            <img :src="candidateImage(timeline.id)" alt="alt">
                          </v-avatar>
                          <span class="mini-header" >{{ candidateProp(timeline.id, 'idName') }}
                          <span>{{ timeline.counts }} голосів</span></span>
                          </h4>
                      </v-card-title>
                      <v-card-text style="padding: 0px;">
                        <chartist ratio="ct-double-octave" type="Line" :data="timeline" :options="timeLineOptions"></chartist>
                        <v-flex xs12 class="ml-4 pb-4">
                          <p>Обирають разом з:</p>
                          <ul>
                            <li v-for="(edge, i) in timeline.edges" :key="'edge'+i"> {{ edge.name }} ({{ edge.counts }})</li>
                          </ul>
                        </v-flex>
                      </v-card-text>
                    </v-card>
                  </v-flex>
                </v-layout>
              </v-card-text>
            </v-card>
          </v-flex>

          </v-layout>
        </v-card-text>
      </v-card>

    </v-flex>

  </v-layout>
</template>

<style>

.sort.asc i {
  transform: rotate(180deg);
}

.user-image {
  position: relative;
}

.user-image .v-responsive__content > div {
  width: 24px;
  height: 24px;
  border-radius: 12px;
  left: 5px;
  bottom: 5px;
  position: absolute; 
}

.user-image .v-responsive__content > div.check {
  background: #43A047; 
}

.user-image .v-responsive__content > div.close {
  background: #F4511E; 
}

.user-image .v-responsive__content > div > i {
  position: relative;
  top: 4px;
  font-size: 18px;
  font-weight: bold;
}

.links a {
  text-decoration: none;
}

.links .divider {
  padding: 0px 5px;
}

.ct-series-a .ct-line {
  /* Set the colour of this series line */
  stroke: green;
  /* Control the thikness of your lines */
  stroke-width: 1px;
}

span[style*="height: 30px; width: 110px;"] {
  height: 42px !important;
}

.mini-header {
  position: relative;
  font-weight: bold;
  top: 12px;
}

.mini-header > span {
  position: absolute;
  font-weight: 400;
  font-size: 12px;
  padding: 1px 6px;
  background: #EEE;
  left: 0px;
  top: -22px;
  width: 90px;
  text-align: center;
}
</style>

<script>
const fetch = require('node-fetch')

export default {
  methods: {
    remove (item, filter) {
      const index = this.filters[filter].indexOf(item)
      if (index >= 0) this.filters[filter].splice(index, 1)
    },
    setTimeRangeFilter (event) {
      this.filters.timeRange = [this.timeRange[0], this.timeRange[1]]
    },
    setChoiceRangeFilter (event) {
      this.filters.choiceRange = [this.choiceRange[0], this.choiceRange[1]]
    },
    formatDate (val) {
      val = new Date(val).toISOString().slice(5, 16)
      val = val.replace(/-/, '.').replace(/T/, ' ')
      return val
    },
    setSort (val) {
      if (val === 'candidate') this.sortType = 'asc'
      if (val === 'counts') this.sortType = 'desc'
    },
    candidateFiltered (name) {
      return new RegExp(this.filter, 'gi').test(name)
    },
    candidateImage (id) {
      if (this.candidates[id].photo) return 'https://gromrada.mva.gov.ua/candidates/small/' + this.candidates[id].photo
      return ''
    },
    candidateProp (id, prop) {
      if (this.candidates[id][prop]) return this.candidates[id][prop]
      return false
    },
    mobileProp (id, prop) {
      return mobile[id][prop]
    },
    success (rating) {
      return rating <= 15 ? 'check' : 'close'
    },
    chartOptions (value) {
      return { ...options[value] }
    },
    getCandidatesTimeLineChart () {
      let self = this
      let data = this.filteredCandidatesCount.slice(0, 30)
      let choices = this.filteredData.filter(el => el.choiceLength > 1)
      choices = this.filteredData.map(el => el.choice)

      data = data.map(el => {
        let counts = getCountsBySpecifiedScale(self.filteredData, self.typeOfTime, el.id, self.currentTimeScale)
        if (this.typeOfTime === 'hours') {
          counts = counts.map(el => {
            return {
              x: new Date(el[0] + ':00'),
              y: el[1]
            }
          })
        } else {
          counts = counts.map(el => {
            return {
              x: new Date(el[0]),
              y: el[1]
            }
          })
        }
        return {
          id: el.id,
          counts: el.counts,
          edges: this.edges(el.id, choices),
          series: [{
            name: 'series-1',
            data: counts
          }]
        }
      })
      this.timelines = data
    },
    edges (id, choices) {
      choices = choices.filter(el => el.includes(id))
      let edges = choices.reduce((obj, el) => {
        for (let p of el) {
          let value = (typeof obj[p] === 'undefined') ? 1 : obj[p] + 1
          obj[p] = value
        }
        return obj
      }, {})
      edges = Object.keys(edges).map(el => {
        return {
          name: this.candidates[el].idName,
          counts: edges[el]
        }
      })
      edges = sort(edges, 'counts')
      edges = edges.slice(1, 10)
      return edges
    }
  },
  computed: {
    current () {
      return this.$store.getters.current
    },
    filteredData () {
      let data = this.data
      data = data.filter(el => el.date >= this.filters.timeRange[0])
      data = data.filter(el => el.date <= this.filters.timeRange[1])
      data = data.filter(el => el.choiceLength >= this.filters.choiceRange[0])
      data = data.filter(el => el.choiceLength <= this.filters.choiceRange[1])
      if (this.filters.mobile.length) data = data.filter(el => this.filters.mobile.includes(el.mobile))
      return data
    },
    candidatesCount () {
      let self = this
      if (this.current !== 'main') return false
      let counts = getCandidatesCounts(this.data, Object.keys(this.candidates))
      counts = counts.map(el => { return { id: el[0], candidate: self.candidates[el[0]].name, counts: el[1] } })
      counts = sort(counts, 'counts')
      counts = counts.map((el, index) => { return Object.assign({ rating: index + 1 }, el) })
      if (!(this.sort === 'counts' && this.sortType === 'desc')) counts = sort(counts, this.sort, this.sortType)
      return counts
    },
    candidatesChart () {
      let counts = getCandidatesCounts(this.filteredData, Object.keys(this.candidates))
      counts = doubleArray2Object(counts)
      let chartData = createChartData(counts)
      return chartData
    },
    total () {
      return this.filteredData.length
    },
    timeLineCounts () {
      return getCounts(this.filteredData, this.typeOfTime)
    },
    timeLine () {
      if (this.typeOfTime === 'hours') {
        return this.timeLineCounts.map(el => {
          return {
            x: new Date(el[0] + ':00'),
            y: el[1]
          }
        })
      } else {
        return this.timeLineCounts.map(el => {
          return {
            x: new Date(el[0]),
            y: el[1]
          }
        })
      }
    },
    currentTimeScale () {
      return this.timeLineCounts.map(el => el[0])
    },
    timeStep () {
      if (this.typeOfTime === 'hours') return 1000 * 60 * 60
      if (this.typeOfTime === 'minutes') return 1000 * 60
    },
    timeLineChart () {
      let data = this.timeLine
      return {
        series: [{
          name: 'series-1',
          data: data
        }]
      }
    },
    timeLineOptions () {
      return Object.assign(options['line'], { showLine: true })
    },
    filteredCandidatesCount () {
      let self = this
      let counts = getCandidatesCounts(this.filteredData, Object.keys(this.candidates))
      counts = counts.map(el => { return { id: el[0], candidate: self.candidates[el[0]].name, counts: el[1] } })
      counts = sort(counts, 'counts')
      return counts
    },
    top15Candidates () {
      return this.filteredCandidatesCount.slice(0, 15)
    },
    top15CandidatesChart () {
      let data = this.top15Candidates.reduce((obj, el) => {
        let candidate = el.candidate.replace(/^(.*?) (.).*? (.).*/, '$1 $2. $3.')
        obj[candidate] = el.counts
        return obj
      }, {})
      let chartData = createChartData(data)
      return chartData
    },
    mobileCounts () {
      let counts = getPhoneCounts(this.filteredData)
      return counts
    },
    mobileFilter () {
      let counts = this.mobileCounts
      counts = counts.map(el => { return { mobile: el[0], counts: el[1] } })
      return counts
    },
    mobileCountsChart () {
      let counts = doubleArray2Object(this.mobileCounts)
      let chartData = createChartData(counts)
      return chartData
    },
    choiceCounts () {
      let counts = getChoiceCounts(this.filteredData, this.maxChoice)
      counts = counts.filter(el => el[1] !== 0)
      counts = doubleArray2Object(counts)
      return counts
    },
    choiceCountsChart () {
      let chartData = createChartData(this.choiceCounts)
      return chartData
    }
  },
  async asyncData (context) {
    let path = 'http://localhost:3001'
    let candidatesData = await fetch(path + '/candidates.json')
    candidatesData = await candidatesData.json()
    let candidates = candidatesData.candidates
    candidates = candidates.map(el => {
      el.name = toTitleCase(el.name.replace(/\s+/g, ' '))
      el.idName = el.name.replace(/^(.*?) (.).*? (.).*/, '$1 $2. $3.')
      return el
    })
    candidates = candidates.map(el => [el.id, el])
    candidates = doubleArray2Object(candidates)
    let resultsData = await fetch(path + '/public_report.txt')
    resultsData = await resultsData.text()
    let lines = resultsData.split(/\n/g)
    lines.splice(-1, 1)
    let data = lines.map(el => {
      let date = new Date(el.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}/g)[0])
      let choice = el.match(/(?<=SEL=).*?(?= )/g)[0].split(/,/g)
      let choiceLength = choice.length
      let mobile = mobileCodes[el.match(/(?<=MOB=)\d{5}/g)[0]]
      let minutes = el.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}/g)[0]
      let hours = el.match(/^\d{4}-\d{2}-\d{2} \d{2}/g)[0]
      return { date, choice, choiceLength, mobile, minutes, hours }
    })
    let times = data.map(el => el.date)
    let maxDate = Math.max(...times)
    let minDate = Math.min(...times)
    let maxChoice = Math.max(...data.map(el => el.choiceLength))
    return {
      data,
      candidates,
      maxChoice,
      minDate,
      maxDate,
      choiceRange: [1, maxChoice],
      timeRange: [minDate, maxDate],
      filters: {
        timeRange: [minDate, maxDate],
        choiceRange: [1, maxChoice],
        mobile: [],
        candidates: []
      } }
  },
  data () {
    return {
      typeOfTime: 'hours',
      typesOfTime: [
        { id: 'hours', name: 'Години' },
        { id: 'minutes', name: 'Хвилини' }
      ],
      sortOptions: [
        { id: 'counts', name: 'Кількість голосів' },
        { id: 'candidate', name: 'ПІБ' }
      ],
      maxChoice: 1,
      minDate: 0,
      maxDate: 10,
      timeRange: [0, 10],
      choiceRange: [1, 1],
      sort: 'counts',
      filter: '',
      filters: {
        timeRange: [0, 10],
        choiceRange: [1, 1],
        candidates: []
      },
      sortType: 'desc',
      timelines: []
    }
  }
}

let mobileCodes = {
  '38050': 'Vodafone',
  '38066': 'Vodafone',
  '38067': 'Kyivstar',
  '38068': 'Kyivstar',
  '38073': 'Lifecell',
  '380891': 'Datagroup',
  '380892': 'Ukrtelecom',
  '380893': 'Global',
  '380894': 'O3',
  '380895': 'Linkom-3000',
  '380896': 'Vodafone',
  '380897': 'Kyivstar',
  '380899': 'Velton',
  '38091': 'Trimob',
  '38092': 'Peoplenet',
  '38093': 'Lifecell',
  '38094': 'Intertelecom',
  '38095': 'Vodafone',
  '38096': 'Kyivstar',
  '38097': 'Kyivstar',
  '38098': 'Kyivstar',
  '38099': 'Vodafone'
}

let mobile = {
  'Vodafone': {
    name: 'Vodafone Україна',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Vodafone_Ukraine.png/1032px-Vodafone_Ukraine.png'
  },
  'Lifecell': {
    name: 'lifecell',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Lifecell_2016_logo_-_Wordmark.svg/1920px-Lifecell_2016_logo_-_Wordmark.svg.png'
  },
  'Kyivstar': {
    name: 'Київстар',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/e/e0/Kyivstar_logo15.png'
  },
  'Datagroup': {
    name: 'Датагруп',
    photo: 'https://www.datagroup.ua/storage/settings/logo-gr.svg'
  },
  'Ukrtelecom': {
    name: 'Укртелеком',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/d/d2/Ukrtelecom.png'
  },
  'Global': {
    name: 'Global',
    photo: 'http://global.ua/assets/logo_60.png'
  },
  'O3': {
    name: 'О3',
    photo: 'https://o3.ua/img/logo.png'
  },
  'Velton': {
    name: 'Велтон.Телеком',
    photo: 'https://upload.wikimedia.org/wikipedia/uk/0/0f/Velton_telecom.gif'
  },
  'Trimob': {
    name: 'ТриМоб',
    photo: 'https://upload.wikimedia.org/wikipedia/uk/5/52/3mob_logo.png'
  },
  'Peoplenet': {
    name: 'PEOPLEnet',
    photo: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Peoplenet.png/800px-Peoplenet.png'
  }
}

let options = {
  'line': {
    showArea: true,
    showLine: false,
    showPoint: false,
    axisX: {
      labelInterpolationFnc: function (value, index) {
        return index % 2 === 0 ? value : null
      }
    }
  },
  'horizontalBar': {
    seriesBarDistance: 7,
    reverseData: true,
    horizontalBars: true,
    axisY: { offset: 120 }
  },
  'bar': {
    seriesBarDistance: 10
  }
}

function getChoiceCounts (data, maxChoice) {
  let choices = Array.apply(null, { length: maxChoice - 1 }).map(Number.call, Number).map(el => el + 1)
  data = data.map(el => el.choiceLength)
  let counts = choices.map(el => [el, data.filter(x => x === el).length])
  return counts
}

function getPhoneCounts (data) {
  let phones = Object.keys(mobile)
  data = data.map(el => el.mobile)
  let counts = phones.map(el => [el, data.filter(x => x === el).length])
  return counts
}

function getCandidatesCounts (data, cids) {
  data = data.map(el => el.choice)
  let counts = cids.map(el => [el, data.filter(x => x.includes(el)).length])
  return counts
}

function doubleArray2Object (array) {
  let map = new Map(array)
  let obj = map2json(map)
  return obj
}

function getCounts (data, variable) {
  data = data.map(el => el[variable])
  let counts = [...new Set(data)].map(x => [x, data.filter(y => y === x).length])
  return counts
}

function getCountsBySpecifiedScale (data, typeOfTime, id, scale) {
  data = data.filter(el => el.choice.includes(id))
  data = data.map(el => el[typeOfTime])
  let counts = scale.map(x => [x, data.filter(y => y === x).length])
  return counts
}

function map2json (data, obj = {}) {
  for (let [key, value] of data) obj[key] = value
  return obj
}

function createChartData (obj) {
  return {
    labels: Object.keys(obj),
    series: [Object.values(obj)]
  }
}

function sort (array, by, type = 'desc') {
  if (typeof array[0][by] === 'number') return type === 'asc' ? array.sort((a, b) => a[by] - b[by]) : array.sort((a, b) => b[by] - a[by])
  return type === 'asc' ? array.sort((a, b) => a[by].localeCompare(b[by])) : array.sort((a, b) => b[by].localeCompare(a[by]))
}

let titleCasePattern = /([^a-zа-яєіїґ'’]|^)([a-zа-яєіїґ])/gi
function toTitleCase (s) {
  return s.toLowerCase().replace(titleCasePattern, string => string.toUpperCase())
}
</script>
